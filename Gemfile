source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'
# Use sqlite3 as the database for Active Record

gem 'pg'

# Use Puma as the app server
gem 'puma', '~> 3.11'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Custom attributes for endpoints
gem 'active_model_serializers'

# Pagination
gem 'api-pagination'
gem 'kaminari'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# Access jsonb attributes like normal ActiveRecord model attributes
gem 'jsonb_accessor'

# App Insights for Azure
gem 'pkg-config', '~> 1.3.2'
gem 'application_insights'

gem "sentry-raven"

group :development, :test do
  # add info about db structure to models and other files
  gem 'annotate'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # GOV.UK interpretation of rubocop for linting Ruby
  gem 'govuk-lint'

  # Test framework
  gem 'rspec-rails'

  # Prettyprint in console
  gem 'awesome_print'

  # A little extra console goodness
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'

  gem 'rb-readline'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Output scaffold commands based on schema
  gem 'schema_to_scaffold'
end

group :test do
  gem 'factory_bot_rails', '~> 5.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'faker'
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem "rspec_junit_formatter"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
