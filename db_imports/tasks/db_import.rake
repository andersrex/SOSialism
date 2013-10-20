require 'db_imports'
require 'neography'

INPATIENT_CSV_PATH = File.expand_path('../../../data/hospital_charges/in_patient.csv', __FILE__)
OUTPATIENT_CSV_PATH = File.expand_path('../../../data/hospital_charges/outpatient.csv', __FILE__)

namespace :db_import do
  desc 'import hospitals'
  task :import_hospitals do
    init_db
    data_flow = load_csv
    DbImports.load_hospitals(data_flow)
  end

  desc 'associate relevant doctors'
  task :associate_relevant_doctor do
    init_db
    DbImports.associate_relevant_doctors
  end

  desc 'wipe graph'
  task :wipe_graph do
    wipe_graph
  end

  # helpers
  def init_db
    Neography.configure do |config|
      config.protocol       = "http://"
      config.server         = "localhost"
      config.port           = 7474
      config.directory      = ""  # prefix this path with '/'
      #config.cypher_path    = "/cypher"
      #config.gremlin_path   = "/ext/GremlinPlugin/graphdb/execute_script"
      config.log_file       = "neography.log"
      config.log_enabled    = false
      config.max_threads    = 20
      config.authentication = nil  # 'basic' or 'digest'
      config.username       = nil
      config.password       = nil
      #config.parser         = MultiJsonParser
    end
  end

  def wipe_graph
    Neography.configure do |config|
      config.protocol       = "http://"
      config.server         = "localhost"
      config.port           = 7474
      config.directory      = ""  # prefix this path with '/'
                                  #config.cypher_path    = "/cypher"
                                  #config.gremlin_path   = "/ext/GremlinPlugin/graphdb/execute_script"
      config.log_file       = "neography.log"
      config.log_enabled    = false
      config.max_threads    = 20
      config.authentication = nil  # 'basic' or 'digest'
      config.username       = nil
      config.password       = nil
      #config.parser         = MultiJsonParser
    end

    neo = Neography::Rest.new
    neo.execute_query('start n=node(*) match n-[r?]->() delete r, n')
  end

  # return the CSV Enumerable
  def load_csv
    f_handle = CSV.open(INPATIENT_CSV_PATH,
                        :col_sep => ",",
                        :headers => true,
                        :return_headers => false )

    f_handle
  end

end