require_relative '../db/db'
require 'sinatra'
require 'haml'
require 'json/ext'

configure do
  mongo = MongoDB.new
  set :db, mongo.db
  set :grid, mongo.grid
  set :cfg, mongo.cfg
end


helpers do

  def obj_id(id)
    BSON::ObjectId.from_string(id)
  end

end

get '/' do
  haml :index
end

get '/screenshots/:id' do |id|
  content_type :png
  settings.grid.get(obj_id(id)).read
end

get '/reports' do
  content_type :json
  settings.db[settings.cfg['reports_coll']].find.to_a.to_json
end

get '/reports/view/:id' do |id|
  @report = settings.db[settings.cfg['reports_coll']].find_one(:_id => obj_id(id))
  haml :report
end