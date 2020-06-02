require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ManageCoursesBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.active_record.pluralize_table_names = false

    config.action_dispatch.rescue_responses = {
      "Pundit::NotAuthorizedError" => :forbidden,
      "PG::ConnectionBad" => :service_unavailable,
      "AASM::InvalidTransition" => :bad_request,
    }

    # https://github.com/rails/rails/commit/ddb6d788d6a611fd1ba6cf92ad6d1342079517a8
    config.action_dispatch.return_only_media_type_on_content_type = false
    config.autoload_paths += %W(#{config.root}/app/models/subjects)

    config.action_mailer.delivery_job = "ActionMailer::MailDeliveryJob"

    config.skylight.environments = Settings.skylight.enable ? [Rails.env] : []
  end
end
