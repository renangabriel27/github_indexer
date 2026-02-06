require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless=new')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Configure default driver to headless for all tests
Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome

RSpec.configure do |config|
  # Configure both :system and :feature tests to use headless
  config.before(:each, type: :system) do |example|
    Capybara.current_driver = :headless_chrome
  end

  config.before(:each, type: :feature) do |example|
    Capybara.current_driver = :headless_chrome
  end
end
