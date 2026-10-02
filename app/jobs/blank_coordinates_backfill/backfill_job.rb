module BlankCoordinatesBackfill
  class BackfillJob < ApplicationJob
    self.queue_adapter = :solid_queue
    queue_as :low_priority
    without_auto_retry
    fail_without_retry_on ActiveRecord::Deadlocked

    def perform(recruitment_cycle_year, dry_run: false)
      DataHub::BlankCoordinatesBackfill::JobOrchestrator.start_backfill(
        recruitment_cycle_year,
        dry_run:,
      )
    end
  end
end
