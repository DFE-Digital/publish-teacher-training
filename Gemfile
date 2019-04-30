source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'

# Use PostgreSQL as the database for Active Record
gem 'pg'

# Authorisation
gem 'pundit'

# Use Puma as the app server
gem 'puma', '~> 3.12'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Custom attributes for endpoints
gem 'active_model_serializers'

# Pagination
gem 'api-pagination'
gem 'kaminari'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# JSON:API Ruby Client
gem 'jsonapi-rails'
gem 'jsonapi-rb'

# Access jsonb attributes like normal ActiveRecord model attributes
gem 'jsonb_accessor'

# App Insights for Azure
gem 'application_insights'
gem 'pkg-config', '~> 1.3.7'

# Sending exceptions to sentry
gem 'sentry-raven'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# For encoding/decoding web token used for authentication
gem 'jwt'

# Formalise config settings with support for env vars
gem 'config'

# For building cmdline apps (mcb)
gem 'cri'

# Build pretty tables in the terminal
#   table_print handles ActiveRecord objects and collections really nicely
gem 'table_print'
#   terminal-table is a bit more flexible allowing us to use a headers column
gem 'terminal-table'

# For querying third party APIs
gem 'faraday'

# UK postcode parsing and validation for Ruby
gem 'uk_postcode'

# For change history on provider, courses, sites, etc
gem 'audited', '~> 4.7'

# State machine to track users through their onboarding journey
gem 'aasm'

# Handle data migrations
gem 'data_migrate'

group :development, :test do
  # add info about db structure to models and other files
  gem 'annotate'

  # Prettyprint in console
  gem 'awesome_print'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # GOV.UK interpretation of rubocop for linting Ruby
  gem 'govuk-lint'

  # A little extra console goodness
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'

  gem 'rails-controller-testing'

  gem 'rb-readline'

  # Enable shorter notation for rspec one-liners
  gem 'rspec-its'

  # Test framework
  gem 'rspec-json_matchers'
  gem 'rspec-rails'

  # A Ruby static code analyzer and formatter
  gem 'rubocop', require: false

  # Make diffs of Ruby objects much more readable
  gem 'super_diff'

  # Allow us to freeze time in tests
  gem 'timecop'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Output scaffold commands based on schema
  gem 'schema_to_scaffold'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Make HTTP requests fun again
  gem 'httparty'

  # Run tests automatically
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 5.0'
  gem 'fakefs', require: 'fakefs/safe'
  gem 'faker'
  gem "jsonapi-rspec"
  gem "rspec_junit_formatter"
  gem 'shoulda-matchers', '~> 4.0'
  gem 'simplecov', require: false
  gem 'webmock'
end
