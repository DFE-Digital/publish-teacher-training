# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  discard_on ActiveJob::DeserializationError

  retry_on ActiveRecord::Deadlocked

  # Opt-in: discard StandardError with no Active Job auto-retries.
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

  # Override a retry/discard handler inherited from ApplicationJob or declared
  # earlier in a subclass. Solid Queue records the raised error for an operator.
  def self.fail_without_retry_on(*exceptions)
    rescue_from(*exceptions) do |error|
      raise error
    end
  end

  # Opt-in for Solid Queue jobs that are safe to run again: Solid Queue has no
  # Sidekiq-style auto-retries, so retry any error a few times with backoff
  # before it lands in solid_queue_failed_executions.
  #
  # Re-declare the DeserializationError discard after the StandardError retry so
  # LIFO `rescue_from` still drops jobs whose records have been deleted.
  def self.retry_on_failure(attempts: 3)
    retry_on StandardError, attempts:, wait: :polynomially_longer
    discard_on ActiveJob::DeserializationError
  end
end
