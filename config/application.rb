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
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ManageCoursesBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.active_record.pluralize_table_names = false

    config.action_dispatch.rescue_responses = {
      'Pundit::NotAuthorizedError' => :forbidden,
      'PG::ConnectionBad' => :service_unavailable,
      'AASM::InvalidTransition' => :bad_request,
      'Pagy::OverflowError' => :bad_request
    }

    # https://github.com/rails/rails/commit/ddb6d788d6a611fd1ba6cf92ad6d1342079517a8
    config.action_dispatch.return_only_media_type_on_content_type = false
    config.autoload_paths += %W[#{config.root}/app/models/subjects]

    config.action_mailer.delivery_job = 'ActionMailer::MailDeliveryJob'
    config.action_mailer.deliver_later_queue_name = 'mailers'

    config.session_store :cookie_store, key: Settings.cookies.session.name, httponly: true

    config.skylight.environments += Settings.skylight.enable ? [Rails.env] : []
    config.skylight.logger = SemanticLogger[Skylight]
    config.skylight.log_level = :fatal
    config.skylight.probes += ['active_job']
    config.skylight.native_log_level = :fatal

    config.view_component.preview_paths = [Rails.root.join('spec/components')]
    config.view_component.preview_route = '/support/view_components'
    config.view_component.default_preview_layout = 'component_preview'
    config.view_component.preview_controller = 'Support::ComponentPreviewsController'
    config.view_component.show_previews = !Rails.env.production?

    config.analytics = config_for(:analytics)

    config.exceptions_app = routes
    config.active_job.queue_adapter = :sidekiq

    config.log_tags = [:request_id]
    config.log_level = Settings.log_level
  end
end
