# frozen_string_literal: true

# Use different Capybara ports when running tests in parallel
if ENV['TEST_ENV_NUMBER']
  Capybara.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i
end

# Cannot use puma, we may need to upgrade rackup > 3
Capybara.server = :webrick
Capybara.javascript_driver = :selenium_chrome_headless

RSpec.configure do |config|
  screen_size = [1400, 1400]

  config.before(:each, type: :system) do
    service = self.class.metadata[:service]

    Capybara.app_host = "http://www.#{service}-test.lvh.me"
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size:
  end

  config.before(:each, :js_browser, type: :system) do
    driven_by :selenium, using: :chrome, screen_size:
  end
end
