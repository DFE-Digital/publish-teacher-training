module BlankCoordinatesBackfill
  class BackfillJob < ApplicationJob
    self.queue_adapter = :solid_queue
    queue_as :default
    without_auto_retry

    def perform(recruitment_cycle_year, dry_run: false)
      DataHub::BlankCoordinatesBackfill::JobOrchestrator.start_backfill(
        recruitment_cycle_year,
        dry_run:,
      )
    end
  end
end
