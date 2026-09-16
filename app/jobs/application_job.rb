# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  retry_on ActiveRecord::Deadlocked

  discard_on ActiveJob::DeserializationError

  # No Active Job retries for StandardError. The terminal block reports and does
  # not re-raise: a bare `retry_on ..., attempts: 0` re-raises after AJ gives up,
  # and Sidekiq's JobWrapper (retry: true) would then apply its default retries
  # while the global adapter is still :sidekiq.
  def self.without_auto_retry
    retry_on StandardError, attempts: 0 do |_job, error|
      Rails.error.report(error, source: "application.active_job")
    end
  end
end
