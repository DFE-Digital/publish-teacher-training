# frozen_string_literal: true

# rails_semantic_logger 5 logs this event itself and leaves Postgres DETAIL lines
# in the message. Drop that subscriber and log the redacted line here instead.
# unsubscribe by event name clears every listener for this event, which is what we
# want here so only the redacted handler remains.
Rails.application.config.after_initialize do
  ActiveSupport::Notifications.unsubscribe("rescue_from_callback.action_controller")

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
