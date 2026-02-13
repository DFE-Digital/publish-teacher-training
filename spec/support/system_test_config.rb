# frozen_string_literal: true

# Use different Capybara ports when running tests in parallel
Capybara.server_port = 9887 + ENV["TEST_ENV_NUMBER"].to_i if ENV["TEST_ENV_NUMBER"]

Capybara.server = :puma

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: :chromium,
    headless: true,
  )
end

Capybara.register_driver(:playwright_headed) do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: :chromium,
    headless: false,
  )
end

Capybara.javascript_driver = :playwright

# Allow Capybara to click a <label> even if its corresponding <input> isn't visible on screen.
# This needs to be enabled when using custom-styled checkboxes and radios, such as those
# in the GOV.UK Design System.
Capybara.automatic_label_click = true

# Playwright's auto-waiting benefits from a slightly higher max wait
Capybara.default_max_wait_time = 15

RSpec.configure do |config|
  config.before(:each, :js_browser, type: :system) do
    Capybara.current_driver = :playwright_headed
  end
end
