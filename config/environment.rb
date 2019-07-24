# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Rails.application.configure do
  config.action_controller.action_on_unpermitted_parameters = :raise

  config.active_job.queue_adapter = :async
end
