require 'mongo'
require 'bson'
require 'yaml'

module Mongo

  class MongoDB

    def initialize
      cfg = YAML::load(File.open("#{File.dirname(__FILE__)}/config.yaml"))
      @db = Mongo::MongoClient.new(cfg['host'], cfg['port']).db(cfg['db_name'])
      @grid = Mongo::Grid.new(@db)
      @reports = @db[cfg['reports_coll']]
      @results = @db[cfg['results_coll']]
    end

    # helpers
    def _id(id) BSON::ObjectId.from_string(id); end

    # screenshots methods
    def add_screenshot(screenshot) @grid.put(screenshot); end
    def get_screenshot(id)@grid.get(_id(id)); end

    # report methods
    def add_report(report) @reports.insert(report); end
    def get_report(id) @reports.find_one(:_id => _id(id)); end
    def get_reports; @reports.find; end
    def remove_report(id) @reports.remove(:_id => _id(id)); end

    # results methods
    def add_result(result) @results.insert(result); end
    def get_result(id) @results.find_one(:_id => _id(id)); end

  end

end
