# frozen_string_literal: true

# Clears finished Solid Queue jobs past `clear_finished_jobs_after`, scheduled
# by Sidekiq Cron while the Solid Queue scheduler is off. Remove at the global
# adapter cutover, when recurring.yml's clear_solid_queue_finished_jobs runs.
class SolidQueueFinishedJobsCleanupJob < ApplicationJob
  self.queue_adapter = :solid_queue
  queue_as :low_priority

  def perform
    SolidQueue::Job.clear_finished_in_batches(sleep_between_batches: 0.3)
  end
end
