require_relative '../screen_test/screen_test'
require 'selenium-webdriver'



class Messages < ScreenTest::MongoUnit

  def read_message_test
    @driver.get 'https://e.mail.ru/login'
  end

  def unread_message_test
    @driver.find_element(:name, 'Login2').send_keys login
  end

  def teardown
    @driver.quit
  end

end
