require_relative '../db/db'
require 'selenium-webdriver'
module ScreenTest
  class Unit

    def initialize(local, url, platform, browser, width, height, java_script, tests)
      @browser = browser
      @local = local
      @url = url
      @platform = platform
      @width = width
      @height = height
      @java_script = java_script
      @tests = tests
    end

    def before_all
      @report['start_time'] = Time.now.to_i
    end

    def before_setup
      if @local
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
    end

    def setup; end
    def after_setup; end

    def before_teardown; end
    def teardown; end
    def after_teardown; end
    def after_all; end

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


    def run_test(test_method)
      do_setup
      self.send test_method
      do_teardown
    end

    def execute_tests
      before_all
        @tests.each do |test_method|
          begin
            @report['tests'][test_method]['start_time'] = Time.now.to_i
            @test_method = test_method
            run_test test_method
            @report['tests'][test_method]['status'] = 'done'
          rescue Exception => e
            @report['tests'][test_method]['status'] = 'fail'
            @report['tests'][test_method]['error'] = e.to_s
            @driver.quit
          ensure
            @report['tests'][test_method]['end_time'] = Time.now.to_i
          end
        end
      after_all
    end

  end


  class MongoUnit < Unit

    def initialize(local, url, platform, browser, width, height, java_script, tests)
      super
      @db = Mongo::MongoDB.new
      @report = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
    end

    def before_all
      super
      @report['total'] = @tests.length
    end

    def before_setup
      super
      @report['tests'][@test_method.to_s]['screenshots'] = []
    end

    def after_teardown
      super
    end

    def after_all
      super
      @report['end_time'] = Time.now.to_i
      @report
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

