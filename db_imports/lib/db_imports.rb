require 'csv'
require 'mongo'
require 'geocoder'

require 'db_imports/version'
require 'db_imports/models/doctor'
require 'db_imports/models/hospital'
require 'db_imports/models/operation'

require 'db_imports/bay_area_zip'

module DbImports

  HOSPITAL_SLUG_INDEX = 'hospital_slug'
  OPERATION_SLUG_INDEX = 'operation_slug'
  PRICE_VALUE_INDEX = 'price_value'
  TYPE_INDEX = 'data_type'

  attr_accessor :neo, :mongo

  def self.slugify(string)
    string.gsub(/[^\w\s]+/,'').gsub(/\s+/,' ').gsub(' ','-').downcase
  end

  def self.load_hospitals(data)

    Geocoder.configure(
      :lookup => :google
    )

    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG

    # initialize the DB
    @neo ||= Neography::Rest.new
    @neo.create_node_index(HOSPITAL_SLUG_INDEX) unless
        @neo.list_node_indexes.nil? or
        @neo.list_node_indexes.include? HOSPITAL_SLUG_INDEX
    @neo.create_node_index(OPERATION_SLUG_INDEX) unless
        @neo.list_node_indexes.nil? or
        @neo.list_node_indexes.include? OPERATION_SLUG_INDEX
    @neo.create_relationship_index(PRICE_VALUE_INDEX) unless
        @neo.list_relationship_indexes.nil? or
        @neo.list_relationship_indexes.include? PRICE_VALUE_INDEX
    @neo.create_node_index(TYPE_INDEX) unless
        @neo.list_node_indexes.nil? or
        @neo.list_node_indexes.include? TYPE_INDEX


    # header
    # DRG Definition,
    # Provider Id,
    # Provider Name,
    # Provider Street Address,
    # Provider City,
    # Provider State,
    # Provider Zip Code,
    # Hospital Referral Region Description,
    # Total Discharges ,
    # Average Covered Charges ,
    # Average Total Payments

    data.each{|d|

      next unless BAY_AREA_ZIP.include? d['Provider Zip Code'].to_i

      # hospitals
      hospital = {}
      hospital['street'] = d['Provider Street Address'].split(' ').map{|x| x.capitalize}.join(' ')
      hospital['city'] = d['Provider City'].split(' ').map{|x| x.capitalize}.join(' ')
      hospital['state'] = d['Provider State']
      hospital['zip'] = d['Provider Zip Code']
      hospital['name'] = self._clean_up_hospital_name(d['Provider Name'])
      hospital['uid'] = d['Provider Id']
      hospital['slug'] = self.slugify(hospital['name'])
      hospital['type'] = 'hospital'

      hospital_node = @neo.get_node_index(HOSPITAL_SLUG_INDEX, 'slug', hospital['slug'])
      if hospital_node.nil?
        hospital['loc'] = Geocoder.coordinates(
            "#{hospital['street']}, #{hospital['city']}, #{hospital['state']}"
        )
        sleep 2
        logger.debug("hospital[#{hospital['slug']}] gets loc[#{hospital['loc']}]")
        hospital_node = @neo.create_node(hospital)
        @neo.add_node_to_index(HOSPITAL_SLUG_INDEX, 'slug', hospital['slug'], hospital_node)
        @neo.add_node_to_index(TYPE_INDEX, 'type', hospital['type'], hospital_node)
        logger.debug("#{hospital['slug']} added to index #{HOSPITAL_SLUG_INDEX}")
      end

      # operations
      operation = {}
      operation['name'] = self._clean_up_operation_name(d['DRG Definition'])
      operation['slug'] = slugify(operation['name'])
      operation['type'] = 'operation'
      # create the operation
      operation_node = @neo.get_node_index(OPERATION_SLUG_INDEX, 'slug', operation['slug'])
      if operation_node.nil?
        operation_node = @neo.create_node(operation)
        @neo.add_node_to_index(OPERATION_SLUG_INDEX, 'slug', operation['slug'], operation_node)
        @neo.add_node_to_index(TYPE_INDEX, 'type', operation['type'], operation_node)
        logger.debug("#{operation['slug']} added to index #{OPERATION_SLUG_INDEX}")
      end

      # price
      price = {}
      price['total_discharge'] = d[' Total Discharges '].to_i
      price['avg_covered_charge'] = d[' Average Covered Charges '].to_i
      price['avg_total_payment'] = d[' Average Total Payments '].to_i
      price_relationship = @neo.create_relationship('charges',
                                      hospital_node, operation_node)
      @neo.add_relationship_to_index(PRICE_VALUE_INDEX, 'avg_total_payment',
                                     price['avg_total_payment'], price_relationship)
      @neo.set_relationship_properties(price_relationship, price)
      logger.debug("price[#{price['avg_total_payment']}] relationship added to hospital[#{hospital['slug']}] and operation[#{operation['slug']}]")
    }

  end

  def self.associate_relevant_doctors
    # We retrive all the hospital name
    # We retrive all the hospital address
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG

    # initialize the DB
    @neo ||= Neography::Rest.new
    @neo.create_node_index(HOSPITAL_SLUG_INDEX) unless
        @neo.list_node_indexes.nil? or
        @neo.list_node_indexes.include? HOSPITAL_SLUG_INDEX


    hospital_nodes = @neo.get_node_index(TYPE_INDEX, 'type', 'hospital')

    logger.debug("##{hospital_nodes.size} returned")
    hospital_nodes.each{|node|
      # we want to get the ratings

      # 1. We extract the hospital address
      hospital_address = {
          'street' => self._format_address(node['data']['street']),
          'city' => node['data']['city'],
          'zip' => node['data']['zip'],
          'state' => node['data']['state']
      }
      logger.debug("node[#{node['data']['slug']}] got selected with addr[#{hospital_address}]")

      # 2. We query against the DB for the relevant DB.
      doctor_ratings = self._search_doctors(hospital_address)

      doctor_list = doctor_ratings.map{|doc| doc['slug']}
      logger.debug("node[#{node['data']['slug']} got ##{doctor_list.size} doctors")
      avg_rating_list = doctor_ratings.map{|doc_rating|
        doc_rating['rating']['average_rating'].to_f unless
            doc_rating['rating'].nil? or
            doc_rating['rating']['average_rating'].nil?

      } - [nil]
      if avg_rating_list.size > 0
        avg_rating = avg_rating_list.inject{|a,e| a + e} / avg_rating_list.size.to_f
        logger.debug("node[#{node['data']['slug']} got ##{avg_rating} ratings")
      else
        # FIXME! make it -1
        avg_rating = 0
        logger.debug("node[#{node['data']['slug']} got ##{avg_rating} ratings")
      end

      # 3. We update the hospital data
      @neo.set_node_properties(node, {'doctors' => doctor_list}) unless
          doctor_list.nil? or doctor_list.empty?
      @neo.set_node_properties(node, {'rating' => avg_rating.to_i}) unless avg_rating.nil?

    } unless hospital_nodes.nil?

  end

  def self._search_doctors(opts)

    doctors = []

    self._query_db(opts).each{|doc|
      # extract yelp ratings
      doctor = {}
      doctor['slug'] = doc['slugs'].first
      rating = doc['ratings'].map{|x| x if x['provider'] == 'yelp'}
      rating = rating - [nil]
      doctor['rating'] = rating.first unless rating.nil? or rating.empty?

      doctors << doctor
    }

    doctors
  end

  def self._format_address(address)
    road_acronym = %W(BLVD PARKWAY BOULEVARD WAY RD ROAD ST STREET AVE AVENUE DRIVE DR)

    # clean up numbers
    _output = address.gsub(/\d+/, '')
    # remove address type
    output_parts = _output.strip.gsub(/\s+/, ' ').gsub(/[^\w\s]+/,'').upcase.split(' ') - road_acronym
    # only street strings
    output_parts.join(' ').downcase
  end

  def self._query_db(opts)
    _mongo ||= Mongo::MongoClient.new
    @mongo = _mongo.db('angelhack2013').collection('doctors')


    street_parts = opts['street'].split(' ')
    zip = opts['zip']

    # 1. do single keyword search & do join
    candidates = []
    street_parts.each{|street|
      candidates << @mongo.find(
          {'practices.zip' => zip,
           'practices.street' => /#{street}/i,
           'ratings.provider' => 'yelp'},
          {:fields => ['slugs', 'ratings']}).to_a
    }

    candidates.inject{|a,e| a & e}
  end

  def self._clean_up_hospital_name(name)
    name.strip.split(' ').map{|x| x.capitalize}.join(' ')
  end

  def self._clean_up_operation_name(name)
    name = name.gsub(/(\bW\/O\b)/,'without')
    name = name.gsub(/(\bW\b)/,'with')

    output = name.downcase.gsub(/[^a-z\s]+/,'').strip.gsub(/\s+/,' ')

    output_parts = output.split(' ')
    output_parts.each{|o|
      if ['with','without'].include? o
        o.downcase!
      elsif ['mcc','cc','ccmcc'].include? o
        o.upcase!
      else
        o.capitalize!
      end
    }.join(' ')
  end

end
