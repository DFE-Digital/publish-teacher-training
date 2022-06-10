require_relative "boot"

require "rails/all"
require "active_support/core_ext/integer/time"
require "view_component/compile_cache"
require "govuk/components"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ManageCoursesBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
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
    config.action_controller.action_on_unpermitted_parameters = :raise

    config.session_store :cookie_store, key: "_publish_teacher_training_courses_session", expire_after: 3.days

    config.skylight.environments = Settings.skylight.enable ? [Rails.env] : []
    config.skylight.logger = SemanticLogger[Skylight]
    config.skylight.log_level = :fatal
    config.skylight.native_log_level = :fatal

    config.view_component.preview_paths = [Rails.root.join("spec/components")]
    config.view_component.preview_route = "/view_components"
    config.view_component.preview_controller = "ComponentPreviewsController"
    config.view_component.show_previews = !Rails.env.production?

    config.analytics = config_for(:analytics)

    config.exceptions_app = routes
    config.active_job.queue_adapter = :sidekiq
  end
end
