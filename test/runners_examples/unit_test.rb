require 'test/unit'
require 'selenium-webdriver'


class UnitTest < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
  end

  def test_1
    @driver.get 'https://mail.ru'
    @driver.save_screenshot '1.png'
  end

  def test_2
    @driver.get 'https://mail.ru'
    @driver.save_screenshot '2.png'
  end

  def teardown
    @driver.close
  end

end

