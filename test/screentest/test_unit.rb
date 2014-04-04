require_relative '../../db/db'

class TestUnit

  def initialize
    @test_method = ''
  end

  def before_all; end
  def before_setup; end
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
    public_methods(true).grep(/^test/).each do |test_method|
      @test_method = test_method
      run_test test_method
    end
    after_all
  end

end


class TestUnitMongoReport < TestUnit

  def initialize
    super
    @db = MongoDB.new
    @report = Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
  end

  def before_all
    super
    @report['test_unit'] = self.class.to_s
  end

  def before_setup
    @report['tests'][@test_method.to_s]['screenshots'] = []
  end

  def after_teardown
    super
  end

  def after_all
    super
    puts @report
    @db.add_report(@report)
  end

  def take_screenshot(driver)
    screenshot_id = @db.add_screenshot(driver.screenshot_as(:png))
    @report['tests'][@test_method.to_s]['screenshots'] << screenshot_id
  end

end
