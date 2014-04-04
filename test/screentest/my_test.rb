require_relative 'test_unit'
require 'selenium-webdriver'


class MyTest < TestUnitMongoReport

  def setup
    @driver = Selenium::WebDriver.for :firefox
  end

  def test_1
    @driver.get 'https://mail.ru'
    take_screenshot(@driver)
  end

  def test_2
    @driver.get 'https://mail.ru'
    take_screenshot(@driver)
  end

  def teardown
    @driver.close
  end

end
