source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.4"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1"

# Use Puma as the app server
gem "puma", "~> 5.3"

# Sidekiq for background worker
gem "sidekiq"

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker"

# State machine to track users through their onboarding journey
gem "aasm"

# Data integration with BigQuery
gem "google-cloud-bigquery"

# Used to build our forms and style them using govuk-frontend class names
gem "govuk-components"
gem "govuk_design_system_formbuilder"

# View components are used to encapsulate logic in views
gem "view_component"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Canonical meta tag
gem "canonical-rails"

# DfE Sign-in
gem "omniauth", "~> 1.9"
gem "omniauth_openid_connect", "~> 0.3"
gem "omniauth-rails_csrf_protection"

gem "pkg-config", "~> 1.4.6"

# Parsing JSON from an API
gem "json_api_client"

# For encoding/decoding web token used for authentication
gem "jwt"

# Settings for the app
gem "config"

# Sentry
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"

# Decorate logic to keep it of the views and helper methods
gem "draper"

# Threadsafe storage
gem "request_store"

# Render nice markdown
gem "redcarpet"

# Offshore logging
gem "logstash-logger", "~> 0.26.1"

# Semantic Logger makes logs pretty
gem "rails_semantic_logger"

# Kaminari, pagination templating
gem "pagy"

gem "rubypants"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]

  # Factories to build models
  gem "factory_bot_rails"

  # Get us some fake!
  gem "faker"

  # GOV.UK interpretation of rubocop for linting Ruby
  gem "erb_lint", require: false
  gem "rubocop-govuk"
  gem "scss_lint-govuk"

  # Ability to render JSONAPI
  gem "jsonapi-deserializable"
  gem "jsonapi-renderer"
  gem "jsonapi-serializable"

  # Better use of test helpers such as save_and_open_page/screenshot
  gem "launchy"

  # Debugging
  gem "pry-byebug"
  gem "pry-rails"

  # Run specs locally in parallel
  gem "parallel_tests"

  # Testing framework
  gem "rspec-its"
  gem "rspec-rails", "~> 5.0.1"

  # Make HTTP requests fun again
  gem "httparty"

  # Smoketest, parallel spec
  gem "rspec"
end

group :development do
  # static analysis
  gem "brakeman"

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "listen", ">= 3.0.5", "< 3.7"
  gem "web-console", ">= 3.3.0"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen", "~> 2.0.0"

  # For better errors
  gem "better_errors"
  gem "binding_of_caller"

  # Run tests automatically
  gem "guard"
  gem "guard-rspec", require: false
  gem "guard-rubocop", require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"

  gem "webdrivers", "~> 4.6"

  # Add Junit formatter for rspec
  gem "rspec_junit_formatter"

  gem "webmock"

  # Show test coverage %
  gem "simplecov", "< 0.22", require: false

  # Make diffs of Ruby objects much more readable
  gem "super_diff"

  # Page object for Capybara
  gem "site_prism"

  # Allows assert_template in request specs
  gem "rails-controller-testing"

  gem "timecop"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
