require_relative '../tests/login'
require_relative '../tests/messages'
require_relative '../db/db'

class Executor

  def initialize(local, url, platform, browser, width, height, java_script, all_tests, author)
    @local = local
    @url = url
    @platform = platform
    @browser = browser
    @width = width
    @height = height
    @java_script = java_script
    @all_tests = all_tests
    @author = author
    @db = Mongo::MongoDB.new
  end

  def execute
    report = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
    report['author'] = @author
    report['browser'] = @browser
    if @local
      report['platform'] = 'local'
    else
      report['platform'] = @platform
    end
    report['resolution']['height'] = @height
    report['resolution']['width'] = @width
    report['start_time'] = Time.now.to_i
    test_units_count = @all_tests.length
    result = []
    threads = (0..test_units_count-1).map do |i|
      Thread.new {
        report['test_units'][@all_tests.keys[i]] = Object.const_get(@all_tests.keys[i]).new(@local, @url, @platform, @browser, @width, @height, @java_script, @all_tests.values[i]).execute_tests
      }
    end
    threads.each {|t| t.join}
    report['end_time'] = Time.now.to_i
    # other static
    units_failed = 0
    report['test_units'].each do |unit_name, unit_data|
      passed = 0
      unit_data['tests'].each do |test_name, test_data|
        if test_data['status'] == 'done'
          passed +=1
        end
      end
      unit_data['passed'] = passed
      unit_data['failed'] = unit_data['total'] - passed
      if unit_data['failed'] != 0
        units_failed +=1
      end
    end
    report['total'] = report['test_units'].length
    report['failed'] = units_failed
    report['passed'] = report['total'] - units_failed
    @db.add_report(report)
  end

end



all_tests = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
all_tests['Login'] = ["test_valid_auth", "test_auth_with_wrong_password"]
all_tests['Messages'] = ['read_message_test', 'unread_message_test']


Executor.new(true, nil, nil, 'firefox', 1024, 768, nil, all_tests, 'r.guseinov').execute