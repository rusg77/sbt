require_relative '../db/db'
require 'sinatra'
require 'haml'
require 'json/ext'
require 'mongo/exception'
require 'resque'
require 'redis'
require_relative '../queue/jobs'
require_relative '../screen_test/analyser'

Resque.redis = Redis.new

configure do
  set :mongo, Mongo::MongoDB.new
end


helpers do

end

get '/resque' do
  @info = Resque.info.to_json
end

get '/' do
  @reports = settings.mongo.get_reports
  @results = settings.mongo.get_results
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

get '/reports/json' do
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

get '/reports/view' do
  begin
    @reports = settings.mongo.get_reports
    if @reports
      haml :reports
    else
      content_type :json
      {:status => 'not_exists'}.to_json
    end
  end
end

get '/result/remove/:id' do |id|
  content_type :json
  begin
    settings.mongo.remove_result(id)
    {:status => 'success or not_exists'}.to_json
  rescue BSON::InvalidObjectId
    {:status => 'invalid_id'}.to_json
  end
end

get '/results/json' do
  content_type :json
  settings.mongo.get_results.to_a.to_json
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

get '/results/view' do
  begin
    @results = settings.mongo.get_results
    if @results
      haml :results
    else
      content_type :json
      {:status => 'not_exists'}.to_json
    end
  end
end


get '/analyse' do
  id1, id2 = params[:id1], params[:id2]
  params = Analyser::Analyser.new(id1, id2).analyze
  if params['result']['errors'].length == 0
    Resque.enqueue(Analyse, params)
  end
  content_type :json
  params['result'].to_json
end


get '/execute' do
  # TODO: проверки параметров
  report = JSON.parse(params[:config])
  report['start_time'] = Time.now.to_i
  report['status'] = 'progress'
  puts report
end


get '/units' do
  # TODO: переделать все
  result = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
  files = Dir.entries('../tests') - %w(. ..)
  files.each do |file_name|
    file_content = File.read("../tests/#{file_name}")
    # TODO: не хватать def, чтобы его потом не удалять
    tests = file_content.scan(/def\s\S+_test/)
    tests.each { |test| test.slice! 'def '}
    result[file_name] = tests
  end
  content_type :json
  result.to_json
end













