require_relative '../db/db'
require 'sinatra'
require 'haml'
require 'json/ext'
require 'mongo/exception'
require 'resque'
require 'redis'
require_relative '../queue/jobs'

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
  content_type :json
  begin
    report1, report2 = settings.mongo.get_report(id1), settings.mongo.get_report(id2)
    if report1 != nil and report2 != nil
      errors = []
      if report1['width'] != report2['width'] or report1['height'] != report2['height']
        errors << 'Разрешение отчетов не совпадает'
      end
      # if report1['browser'] != report2['browser']
      #   errors << 'Браузеры отчетов не совпадают'
      # end
      if report1['platform'] != report2['platform']
        errors << 'ОС отчетов не совпадают'
      end
      # если ошибки не найдены
      if errors.length == 0
        result = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
        result['id1'], result['id2'] = id1, id2
        %w(browser platform width height).each do |key|
          result[key] = report1[key]
        end
        result['author'], result['start_time'], result['status']= 'Руслан Гусейнов', Time.now.to_i, 'progress'
        result_id = settings.mongo.add_result(result)
        params = Hash.new
        params['result_id'] = result_id.to_s
        params['report_1'] = report1
        params['report_2'] = report2
        params['result'] = result
        Resque.enqueue(Analyse, params)
        params['result'].to_json
      else
        content_type :json
        {:status => 'invalid_id'}.to_json
      end
    else
      {:status => 'not_exists'}.to_json
    end
  rescue BSON::InvalidObjectId
    {:status => 'invalid_id'}.to_json
  end
end


get '/execute' do
  # TODO: проверки параметров
  config = JSON.parse(params[:config])
  report = config.clone
  report.delete('all_tests')
  report['start_time'] = Time.now.to_i
  report['status'] = 'progress'
  report_id = settings.mongo.add_report(report).to_s
  config['report_id'] = report_id
  Resque.enqueue(Execute, config)
  content_type :json
  report.to_json
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
