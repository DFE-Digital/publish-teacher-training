# frozen_string_literal: true

# Use different Capybara ports when running tests in parallel
Capybara.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i if ENV['TEST_ENV_NUMBER']

# Cannot use puma, we may need to upgrade rackup > 3
Capybara.server = :webrick

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument('--headless=new')
    opts.add_argument('--no-sandbox')
    opts.add_argument('--disable-dev-shm-usage')
    opts.add_argument('--disable-gpu')
    opts.add_argument('--window-size=1400,1400')
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.javascript_driver = :selenium_chrome_headless

# Allow Capybara to click a <label> even if its corresponding <input> isn't visible on screen.
# This needs to be enabled when using custom-styled checkboxes and radios, such as those
# in the GOV.UK Design System.
Capybara.automatic_label_click = true

RSpec.configure do |config|
  screen_size = [3400, 3400]

  config.before(:each, type: :system) do
    service = self.class.metadata[:service]

    Capybara.app_host = "http://www.#{service}-test.lvh.me"
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by :selenium_chrome_headless, using: :headless_chrome, screen_size:

    if Capybara.current_driver == :selenium_chrome_headless
      logs = page.driver.browser.manage.logs.get(:browser)
      logs.each { |log| puts log.message }
    end
  end

  config.before(:each, :js_browser, type: :system) do
    driven_by :selenium, using: :chrome, screen_size:
  end
end
