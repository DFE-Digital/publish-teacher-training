# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require "database_cleaner"
require "spec_helper"
require_relative "./support/system_retry_helper"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "capybara/rspec"
require "capybara/rails"
# Add additional requires below this line. Rails is not loaded until this point!

# Pull in all the files in spec/support automatically.
Dir["./spec/strategies/**/*.rb"].each { |file| require file }

Faker::Config.locale = "en-GB"

# configure shoulda matchers to use rspec as the test framework and full matcher libraries for rails
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Allows us to call `mid_cycle` in the highest context in the specs
extend CycleTimetableHelpers # rubocop:disable Style/MixinUsage

# Allows response.parsed_body to parse JSONAPI responses
# Doesn't work by default with RSpec.
# https://github.com/jsonapi-rb/jsonapi-rails/blob/master/lib/jsonapi/rails/railtie.rb#L47
ActionDispatch::RequestEncoder.register_encoder :jsonapi, response_parser: ->(body) { JSON.parse(body) }

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # add `FactoryBot` methods
  config.include CycleTimetableHelpers
  config.include FactoryBot::Syntax::Methods
  config.include RequestHelpers, type: :controller
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
  config.include ActiveJob::TestHelper, type: :request
  config.include ActiveSupport::Testing::TimeHelpers
  config.include SystemRetryHelper, type: :system

  # start by truncating all the tables but then use the faster transaction strategy the rest of the time.
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction

    postgis_table_count = ActiveRecord::Base.connection.execute(
      "SELECT COUNT(*) FROM spatial_ref_sys;",
    ).field_values("count").flatten.first.to_i

    if postgis_table_count.zero?
      ActiveRecord::Base.connection.execute("DROP EXTENSION IF EXISTS postgis CASCADE;")
      ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS postgis;")
    end

    # Pass a Settings env var to the process to override settings.yml
    #
    # This is mainly used in GH actions for testing matrix
    # ../.github/workflows/build-and-deploy.yml (Jobs: Test)
    Settings.add_source!(ENV.select { |k, _v| k[/SETTINGS__FEATURES_/] })
    Settings.reload!
  end

  # start the transaction strategy as examples are run
  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Report N+1 queries
  if Bullet.enable?
    config.before { Bullet.start_request }
    config.after  { Bullet.end_request }
  end

  ActiveJob::Base.queue_adapter = :test

  config.before(:each, type: :request) do
    service = self.class.metadata[:service]

    host! app_host(service:)
  end

  config.before(:each, type: :feature) do
    service = self.class.metadata[:service]

    Capybara.app_host = app_url(service:)
  end

  config.before(:each, type: :system) do
    service = self.class.metadata[:service]

    Capybara.app_host = app_url(service:)

    driven_by Capybara.current_driver
  end

  config.before do |example|
    if (time = example.metadata[:travel])
      year = Find::CycleTimetable.cycle_year_for_time(time)
      find_or_create(:recruitment_cycle, year:)
      allow(Settings).to receive(:current_recruitment_cycle_year)
        .and_return(year)
    end
  end

  config.around do |example|
    if (time = self.class.metadata[:travel] || example.metadata[:travel])
      Timecop.travel(time) do
        example.run
      end
    else
      example.run
    end
  end

private

  def app_host(service:)
    case service
    when :find    then Settings.find_hosts.first
    when :publish then Settings.publish_hosts.first
    when :api     then Settings.api_hosts.first
    end
  end

  def app_url(service:)
    case service
    when :find    then Settings.find_url
    when :publish then Settings.publish_url
    when :api     then Settings.api_url
    end
  end

  def asset_url(service:)
    case service
    when :find    then development_settings.find_url
    when :publish then development_settings.publish_url
    when :api     then development_settings.api_url
    end
  end

  def development_settings
    @development_settings ||= Config.load_files(Config.setting_files(Rails.root.join("config"), "development"))
  end
end
