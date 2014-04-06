require_relative '../db/db'
require_relative '../compare/rmagic'
require 'sinatra'
require 'haml'
require 'json/ext'
require 'mongo/exceptions'

configure do
  set :mongo, Mongo::MongoDB.new
end


helpers do

end

get '/' do
  haml :index
end

get '/screenshot/:id' do |id|
  begin
    content_type :png
    settings.mongo.get_screenshot(id).read
  rescue BSON::InvalidObjectId
    content_type :json
    {:status => 'invalid_id'}.to_json
  rescue Mongo::GridFileNotFound
    content_type :json
    {:status => 'not_exists'}.to_json
  end

end

get '/reports' do
  content_type :json
  settings.mongo.get_reports.to_a.to_json
end

get '/report/view/:id' do |id|
  begin
    @report = settings.mongo.get_report(id)
    if @report
      haml :report
    else
      content_type :json
      {:status => 'not_exists'}.to_json
    end
  rescue BSON::InvalidObjectId
    content_type :json
    {:status => 'invalid_id'}.to_json
  end
end

get '/report/remove/:id' do |id|
  content_type :json
  begin
    settings.mongo.remove_report(id)
    {:status => 'success or not_exists'}.to_json
  rescue BSON::InvalidObjectId
    {:status => 'invalid_id'}.to_json
  end
end

get '/result/view/:id' do |id|
  begin
    @result = settings.mongo.get_result(id)
    if @result
      haml :result
    else
      content_type :json
      {:status => 'not_exists'}.to_json
    end
  rescue BSON::InvalidObjectId
    content_type :json
    {:status => 'not_exists'}.to_json
  end
end

get '/compare' do
  # TODO: тут нужны многочисленные проверки
  id1, id2 = params[:id1], params[:id2]
  report1, report2 = settings.mongo.get_report(id1), settings.mongo.get_report(id2)
  result = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
  result['id1'], result['id2'] = id1, id2
  result['test_unit'] = report1['test_unit']

  report1['tests'].each do |test_name, test_data|
    result['tests'][test_name]['screenshots'] = []
    test_data['screenshots'].each_with_index do |screenshot1, index|
      screenshot2 = report2['tests'][test_name]['screenshots'][index]
      screenshots_data = []
      screenshots_data << screenshot1
      screenshots_data << screenshot2
      screenshot1 = settings.mongo.get_screenshot(screenshot1).read
      screenshot2 = settings.mongo.get_screenshot(screenshot2).read
      compare_result  = Compare::compare(screenshot1, screenshot2)
      screenshots_data << settings.mongo.add_screenshot(compare_result).to_s
      result['tests'][test_name]['screenshots'] << screenshots_data
    end
  end
  content_type :json
  result['_id'] = settings.mongo.add_result(result)
  result.to_json
end
