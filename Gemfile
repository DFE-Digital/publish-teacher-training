# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "8.0.2"

# Use PostgreSQL as the database for Active Record
gem "pg"

# Authorisation
gem "pundit"

# Use Puma as the app server
gem "puma", "~> 6.6"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Decorate logic to keep it out of the views and helper methods
gem "draper"

# Custom attributes for endpoints
gem "active_model_serializers"

# Pagination for frontend and API
gem "pagy", "~> 9.3"

# JSON:API Ruby Client
gem "jsonapi-rails", github: "DFE-Digital/jsonapi-rails"
gem "jsonapi-rb"

# Access jsonb attributes like normal ActiveRecord model attributes
gem "jsonb_accessor"

# Sending exceptions to sentry
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# For encoding/decoding web token used for authentication
gem "jwt"

# Formalise config settings with support for env vars
gem "config"

# For querying third party APIs
gem "faraday"
gem "faraday-net_http_persistent", "~> 2.3"

# UK postcode parsing and validation for Ruby
gem "uk_postcode"

# For change history on provider, courses, sites, etc
gem "audited", "~> 5.4"

# State machine to track users through their onboarding journey
gem "aasm"

# Allows writing of error full_messages for validations that don't start with the attribute name
gem "custom_error_message", git: "https://github.com/DFE-Digital/custom-err-msg.git", ref: "46a24a4"

# Soft delete
gem "discard"

# Gov Notify
gem "govuk_notify_rails"

# Run jobs in the background. Good enough until we know we need more firepower
# (i.e. SideKiq)
gem "sidekiq"
gem "sidekiq-cron"

# Semantic Logger makes logs pretty
gem "rails_semantic_logger"

# Render nice markdown
gem "redcarpet"
gem "rubypants"

# Thread-safe global state
gem "request_store"

# IoC Container
gem "dry-container"

# For geocoding and geographic logic (e.g: filtering sites by ranges)
gem "geokit-rails"

# Geocoding
gem "geocoder"

gem "open_api-rswag-api", "0.2.0", github: "DFE-Digital/open-api-rswag", tag: "v0.2.0"
gem "open_api-rswag-specs", "0.2.0", github: "DFE-Digital/open-api-rswag", tag: "v0.2.0"
gem "open_api-rswag-ui", "0.2.0", github: "DFE-Digital/open-api-rswag", tag: "v0.2.0"

gem "pg_search"

# End-user application performance monitoring
gem "skylight"

# govuk styling
gem "govuk-components", "~> 5.10.1"
gem "govuk_design_system_formbuilder", "~> 5.10"

# DfE Sign-In
gem "omniauth", "~> 2.1"
gem "omniauth_openid_connect", "~> 0.8"
gem "omniauth-rails_csrf_protection", "~> 1.0"

# Data integration with BigQuery
gem "google-cloud-bigquery"

# Faster JSON serialization
gem "oj"

# Rails 7 CSS and JS Bundling
gem "cssbundling-rails", "~> 1.4"
gem "jsbundling-rails", "~> 1.3"
gem "propshaft"

# for sending analytics data to the analytics platform
gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.15.6"

# Provides an accessible and lightweight autocomplete component for forms
gem "dfe-autocomplete", github: "DFE-Digital/dfe-autocomplete", tag: "v0.2.0"

# For running data migrations
gem "data_migrate", "11.3.0"

# For outgoing http requests
gem "http"

# For configuring domains and assets
gem "rack-cors"

# Rails console colours
gem "colorize"

# for running SQL queries
gem "blazer"

gem "dfe-wizard", require: "dfe/wizard", github: "DFE-Digital/dfe-wizard", tag: "v0.1.1"

group :development, :test do
  # Prettyprint in console
  gem "awesome_print"

  # Better colorized logs
  gem "amazing_print"

  # Help eliminate N+1 queries
  gem "bullet"

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]

  # Linters and formatting
  gem "erb_lint", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-govuk", require: false
  gem "rubocop-rspec_rails", require: false

  # run specs in parallel
  gem "parallel_tests"

  # A little extra console goodness
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"

  gem "rails-erd"

  gem "rb-readline"

  # Enable shorter notation for rspec one-liners
  gem "rspec-its"

  # Enables us to repeatedly evaluate until the underlying matcher passes or the configured timeout elapses
  gem "rspec-wait"

  # Test framework
  gem "rspec-rails", "8.0.1"

  gem "selenium-webdriver"

  # Make diffs of Ruby objects much more readable
  gem "super_diff"

  # Allow us to freeze time in tests
  gem "timecop"

  gem "factory_bot_rails", "~> 6.5"
  gem "fakefs", require: "fakefs/safe"
  gem "faker"

  gem "dotenv"

  # Make HTTP requests fun again
  gem "httparty"
end

group :development do
  # Static analysis
  gem "brakeman"

  gem "listen", ">= 3.0.5", "< 3.10"

  # error handling
  gem "better_errors"
  gem "binding_of_caller"

  # Output scaffold commands based on schema
  gem "schema_to_scaffold"
end

group :test do
  gem "database_cleaner"
  gem "jsonapi-rspec"
  gem "mock_redis"
  gem "rspec_junit_formatter"
  gem "shoulda-matchers", "~> 6.5"
  gem "simplecov", "< 0.23", require: false

  # Page objects
  gem "site_prism", "~> 5.1"

  gem "webmock"

  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "launchy"
end
