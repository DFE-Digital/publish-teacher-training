# frozen_string_literal: true

require_relative "boot"

# Pick the frameworks you want:
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "active_support/core_ext/integer/time"
require "view_component/compile_cache"
require "govuk/components"
require_relative "../app/middleware/request_logging_tags"
require_relative "../app/middleware/store_save_course_intent"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ManageCoursesBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Europe/London"
    # config.eager_load_paths << Rails.root.join("extras")

    config.active_record.pluralize_table_names = false

    config.action_dispatch.rescue_responses = {
      "Pundit::NotAuthorizedError" => :forbidden,
      "PG::ConnectionBad" => :service_unavailable,
      "AASM::InvalidTransition" => :bad_request,
      "Pagy::OverflowError" => :bad_request,
    }

    # https://github.com/rails/rails/commit/ddb6d788d6a611fd1ba6cf92ad6d1342079517a8
    config.action_dispatch.return_only_media_type_on_content_type = false
    config.autoload_paths += %W[#{config.root}/app/models/subjects]

    config.action_mailer.delivery_job = "ActionMailer::MailDeliveryJob"
    config.action_mailer.deliver_later_queue_name = "mailers"

    config.session_store :cookie_store, key: Settings.cookies.session.name, httponly: true, secure: !Rails.env.test? && !Rails.env.development?

    config.skylight.environments += Settings.skylight.enable ? [Rails.env] : []
    config.skylight.logger = SemanticLogger[Skylight]
    config.skylight.log_level = :fatal
    config.skylight.probes += %w[active_job]
    config.skylight.native_log_level = :fatal

    config.view_component.preview_paths = [Rails.root.join("spec/components")]
    config.view_component.preview_route = "/support/view_components"
    config.view_component.preview_controller = "Support::ViewComponentsController"

    show_previews = !Rails.env.production? || Settings.environment.name.in?(%w[qa review])
    config.action_mailer.preview_paths = [Rails.root.join("spec/mailers/previews")]
    config.action_mailer.show_previews = show_previews

    config.analytics = config_for(:analytics)

    config.exceptions_app = routes
    config.active_job.queue_adapter = :sidekiq

    config.log_tags = []
    config.log_level = Settings.log_level

    # Capture candidate "save course" intent during OmniAuth request phase (CSRF-protected POST).
    # Must run after the session middleware so `env["rack.session"]` is available.
    config.middleware.insert_after ActionDispatch::Session::CookieStore, StoreSaveCourseIntent

    # Insert the middlware at the end of the stack
    config.middleware.use RequestLoggingTags

    # Blazer opens its own connection pool from this URL, so it has to describe
    # the database the app is already using. Deriving it from the resolved
    # config follows database.yml, DATABASE_URL and TEST_ENV_NUMBER without
    # restating any of them.
    #
    # This has to be assigned at config time. Blazer's engine reads
    # config/blazer.yml while the initializers run, so an initializer is too
    # late. An unconnectable URL fails far more than Blazer, and silently:
    # spec/config/blazer_spec.rb guards it.
    def read_only_database_url
      db = ActiveRecord::DatabaseConfigurations.new(config.database_configuration)
        .configs_for(env_name: Rails.env, name: "primary")
        .configuration_hash
      userinfo = [db[:username], db[:password]].compact_blank.map { |part| ERB::Util.url_encode(part) }.join(":")
      authority = [
        ("#{userinfo}@" if userinfo.present?),
        db[:host].presence && [db[:host], db[:port].presence].compact.join(":"),
      ].compact.join

      "postgres://#{authority}/#{db[:database]}"
    end
  end
end
