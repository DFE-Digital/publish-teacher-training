# frozen_string_literal: true

module TestJob
  # Harmless Solid Queue canary. Enqueue with
  # `TestJob::DispatcherCanaryJob.set(wait_until: 1.minute.from_now).perform_later`
  # to prove the dispatcher moves scheduled → ready → completed while Sidekiq
  # remains the global adapter.
  class DispatcherCanaryJob < ApplicationJob
    self.queue_adapter = :solid_queue
    queue_as :default

    def perform
      Rails.logger.info(
        message: "Solid Queue dispatcher canary completed",
        job_class: self.class.name,
      )
    end
  end
end
