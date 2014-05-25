require_relative '../screen_test/screen_test'
require 'selenium-webdriver'



class Login < ScreenTest::MongoUnit

  def setup
    @driver.get 'https://e.mail.ru/login'
  end

  # функкция авторизации
  # @param [String] login - имя пользователя, строка
  # @param [String] password - пароль, строка
  def login(login, password)
    # найти элемент для ввода ими пользователя и ввести имя пользователя
    @driver.find_element(:name, 'Login').send_keys login
    # найти элемент для ввода пароля и ввести пароль
    @driver.find_element(:name, 'Password').send_keys password
    # найти кнопку для авторизации и нажать её
    @driver.find_element(:xpath, ".//*[@type='submit']").submit
  end

  def test_valid_auth
    login('dags.adfg', '32167R')
    take_screenshot
  end

  def test_auth_with_wrong_password
    login('dags.adfg', '32167')
    take_screenshot
  end

  def teardown
    @driver.quit
  end

end
