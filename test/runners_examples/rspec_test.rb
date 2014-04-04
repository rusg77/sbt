require 'rspec'
require 'selenium-webdriver'


describe 'Screenshots' do

  before(:each) do
    @driver = Selenium::WebDriver.for :firefox
  end

  it 'screenshot 1' do
    @driver.get 'https://mail.ru'
    @driver.save_screenshot '1.png'
  end

  it 'screenshot 2' do
    @driver.get 'https://mail.ru'
    @driver.save_screenshot '2.png'
  end

  after(:each) do
    @driver.close
  end
end