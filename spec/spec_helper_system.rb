# frozen_string_literal: true

require 'capybara/playwright'

# Use different Capybara ports when running tests in parallel
Capybara.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i if ENV['TEST_ENV_NUMBER']

# Cannot use puma, we may need to upgrade rackup > 3
Capybara.server = :webrick

Capybara.register_driver :playwright do |app|
  Capybara::Playwright::Driver.new(app,
                                   browser_type: :chromium,
                                   headless: false)
end

Capybara.register_driver :playwright_headless do |app|
  Capybara::Playwright::Driver.new(app,
                                   browser_type: :chromium,
                                   headless: true)
end

Capybara.javascript_driver = :playwright_headless

# Allow Capybara to click a <label> even if its corresponding <input> isn't visible on screen.
# This needs to be enabled when using custom-styled checkboxes and radios, such as those
# in the GOV.UK Design System.
Capybara.automatic_label_click = true

RSpec.configure do |config|
  config.before(:each, type: :system) do
    service = self.class.metadata[:service]

    Capybara.app_host = "http://www.#{service}-test.lvh.me"
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by :playwright_headless
  end

  config.before(:each, :js_browser, type: :system) do
    driven_by :playwright
  end
end
