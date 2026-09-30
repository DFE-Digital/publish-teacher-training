# frozen_string_literal: true

Rails.application.config.after_initialize do
  already_logged = ActiveSupport::LogSubscriber.log_subscribers.any? do |subscriber|
    subscriber.is_a?(ActiveSupport::LogSubscriber) && subscriber.respond_to?(:rescue_from_callback)
  end
  next if already_logged

  ActiveSupport::Notifications.subscribe("rescue_from_callback.action_controller") do |event|
    exception = event.payload[:exception]

    Rails.logger.info(
      message: "rescue_from handled #{exception.class}",
      payload: {
        exception: exception.class.name,
        exception_message: exception.message.gsub(PG_DETAIL_REGEX, PG_DETAIL_FILTERED),
        backtrace: exception.backtrace&.first&.delete_prefix("#{Rails.root}#{File::SEPARATOR}"),
      },
    )
  rescue StandardError => e
    Rails.error.report(e, handled: true)
  end
end
