require_relative '../db/db'
require 'selenium-webdriver'
module ScreenTest
  class Unit

    def initialize(url, platform, browser, width, height, java_script, tests)
      @browser = browser
      @url = url
      @platform = platform
      @width = width
      @height = height
      @java_script = java_script
      @tests = tests
      @db = Mongo::MongoDB.new
      @report = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
    end

    def before_all
      @report['start_time'] = Time.now.to_i
      @report['total'] = @tests.length
    end

    def before_setup
      if @platform == 'local'
        case @browser
          when 'firefox'
            @driver = Selenium::WebDriver.for :firefox
          when 'chrome'
            @driver = Selenium::WebDriver.for :chrome
          when 'ie'
            @driver = Selenium::WebDriver.for :ie
          when 'opera'
            @driver = Selenium::WebDriver.for :opera
          when 'safari'
            @driver = Selenium::WebDriver.for :safari
          else
            raise ArgumentError, "unknown driver: #{browser.inspect}"
        end
      else
        @driver = Selenium::WebDriver.for(:remote, opts={
          :browser_name => @browser,
          :url => @url,
          :platform => @platform
        })
      end
      # установка размера окна
      @driver.manage.window.size = Selenium::WebDriver::Dimension.new(1024, 768)
      @report['tests'][@test_method.to_s]['screenshots'] = []
    end

    def setup; end
    def after_setup; end

    def before_teardown; end
    def teardown; end


    def after_teardown
      @report['tests'][@test_method]['end_time'] = Time.now.to_i
    end

    def after_all
      @report['end_time'] = Time.now.to_i
      @report
    end

    def do_setup
      before_setup
      setup
      after_setup
    end

    def do_teardown
      before_teardown
      teardown
      after_teardown
    end


    def execute_tests
      before_all
        @tests.each do |test_method|
          @report['tests'][test_method]['start_time'] = Time.now.to_i
          @test_method = test_method
          do_setup
          begin
            self.send test_method
            @report['tests'][test_method]['status'] = 'done'
          rescue Exception => e
            @report['tests'][test_method]['status'] = 'fail'
            @report['tests'][test_method]['error'] = e.to_s
          end
          do_teardown
      end
      after_all
    end

    def take_screenshot
      if @java_script
        @driver.execute_script(@java_script)
      end
      screenshot_id = @db.add_screenshot(@driver.screenshot_as(:png)).to_s
      @report['tests'][@test_method.to_s]['screenshots'] << screenshot_id
      screenshot_id
    end

  end

end
