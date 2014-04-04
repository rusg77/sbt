require 'mongo'
require 'bson'
require 'yaml'


class MongoDB

  def initialize
    @cfg = YAML::load(File.open("#{File.dirname(__FILE__)}/config.yaml"))
    @db = Mongo::MongoClient.new(@cfg['host'], @cfg['port']).db(@cfg['db_name'])
    @grid = Mongo::Grid.new(@db)
  end

  attr_reader :cfg
  attr_reader :db
  attr_reader :grid

  def add_report(report)
    report_collection = @db['reports']
    report_collection.insert(report)
  end

  def add_screenshot(screenshot)
    @grid.put(screenshot).to_s
  end

end
