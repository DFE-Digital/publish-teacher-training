# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  discard_on ActiveJob::DeserializationError

  retry_on ActiveRecord::Deadlocked

  # Opt-in: discard StandardError with no Active Job / Sidekiq auto-retries.
  # A bare `retry_on ..., attempts: 0` re-raises into Sidekiq's JobWrapper
  # (retry: true) while the global adapter is still :sidekiq.
  #
  # `report: true` sends failures through ActiveSupport::ErrorReporter (Sentry
  # when `config.rails.register_error_subscriber` is enabled).
  #
  # Re-declare Deadlocked retry after the StandardError discard so LIFO
  # `rescue_from` still retries deadlocks (Deadlocked < StandardError).
  def self.without_auto_retry
    discard_on StandardError, report: true
    retry_on ActiveRecord::Deadlocked
  end
end
