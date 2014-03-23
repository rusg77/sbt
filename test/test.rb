#require 'watir-webdriver'
require 'selenium-webdriver'
require_relative '../db/db'

def watir_test
  browser = Watir::Browser.new
  begin
    browser.goto 'http://google.com'
    if browser('Google')
      browser.screenshot.
      puts 'Test passed!'
    else
      puts 'Test failed!'
    end
  ensure
      browser.close
  end
end

def selenium_webdriver_test
  begin
  browser = Selenium::WebDriver.for :firefox
  browser.get 'https://mail.ru'
  #db = DB.new
  #db = DB.get_connection.collection('testData')
  #db.insert({'screenshot' => '123'} )
  #gridFS = MongoDB.get_grid
  db = MongoDB.new
  id = db.get_grid.put(browser.screenshot_as(:png))
  puts id
  db.get_file(id)
  #db.insert({'screenshot' => browser.screenshot_as(:png)[1..1000]})
  #puts browser.screenshot_as(:png).class
  #File.open('123.png', 'wb') { |f| f << browser.screenshot_as(:png) }
  ensure
  browser.close
  end
end

selenium_webdriver_test