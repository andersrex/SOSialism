require 'csv'

require 'db_imports/version'
require 'db_imports/models/doctor'
require 'db_imports/models/hospital'
require 'db_imports/models/operation'

require 'db_imports/bay_area_zip'


module DbImports

  HOSPITAL_SLUG_INDEX = 'hospital_slug'
  OPERATION_SLUG_INDEX = 'operation_slug'
  PRICE_VALUE_INDEX = 'price_value'

  attr_accessor :neo

  def self.slugify(string)
    string.gsub(/[^\w\s]+/,'').gsub(/\s+/,' ').gsub(' ','-').downcase
  end

  def self.aggregate_rating(ratings)
    5.0
  end

  def self.load_hospitals(data)

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
      hospital['street'] = d['Provider Street Address']
      hospital['city'] = d['Provider City']
      hospital['state'] = d['Provider State']
      hospital['zip'] = d['Provider Zip Code']
      hospital['name'] = d['Provider Name']
      hospital['uid'] = d['Provider Id']
      hospital['slug'] = self.slugify(hospital['name'])
      # TODO: FIX THIS!
      #hospital['doctors'] = []
      #hospital['ratings'] = []
      #hospital['rating'] = self.aggregate_rating(hospital['ratings'])
      hospital['rating'] = self.aggregate_rating('FIXME!')

      hospital_node = @neo.get_node_index(HOSPITAL_SLUG_INDEX, 'slug', hospital['slug'])
      if hospital_node.nil?
        hospital_node = @neo.create_node(hospital)
        @neo.add_node_to_index(HOSPITAL_SLUG_INDEX, 'slug', hospital['slug'], hospital_node)
        logger.debug("#{hospital['slug']} added to index #{HOSPITAL_SLUG_INDEX}")
      end

      # operations
      operation = {}
      operation['name'] = d['DRG Definition']
      operation['slug'] = slugify(operation['name'])
      # create the operation
      operation_node = @neo.get_node_index(OPERATION_SLUG_INDEX, 'slug', operation['slug'])
      if operation_node.nil?
        operation_node = @neo.create_node(operation)
        @neo.add_node_to_index(OPERATION_SLUG_INDEX, 'slug', operation['slug'], operation_node)
        logger.debug("#{operation['slug']} added to index #{OPERATION_SLUG_INDEX}")
      end

      # price
      price = {}
      price['total_discharge'] = d[' Total Discharges '].to_f
      price['avg_covered_charge'] = d[' Average Covered Charges '].to_f
      price['avg_total_payment'] = d[' Average Total Payments '].to_f
      price_relationship = @neo.create_relationship('charges',
                                      hospital_node, operation_node)
      @neo.add_relationship_to_index(PRICE_VALUE_INDEX, 'avg_total_payment',
                                     price['avg_total_payment'], price_relationship)
      @neo.set_relationship_properties(price_relationship, price)
      logger.debug("price[#{price['avg_total_payment']}] relationship added to hospital[#{hospital['slug']}] and operation[#{operation['slug']}]")
    }

  end

  def self.load_doctors


  end

  def self.load_operations

  end

end
