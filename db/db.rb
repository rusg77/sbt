require 'mongo'
require 'yaml'


class MongoDB

  def initialize
    cfg = YAML::load(File.open("#{File.dirname(__FILE__)}/config.yaml"))
    @db = Mongo::MongoClient.new(cfg['host'], cfg['port']).db(cfg['db_name'])
    @grid = Mongo::Grid.new(@db)
  end

  def get_connection
    @db
  end

  def get_grid
    @grid
  end

  def get_file(id)
    #id = '532f3b9f5edfc0e17e000001'
    file = @grid.get(id)
    output = File.open('1.png', 'w')
    output << file.read
    output.close

  end
end
