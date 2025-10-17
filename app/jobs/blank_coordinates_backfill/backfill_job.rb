module BlankCoordinatesBackfill
  class BackfillJob < ApplicationJob
    queue_as :default
    retry_on StandardError, attempts: 0

    def perform(recruitment_cycle_year, dry_run: false)
      DataHub::BlankCoordinatesBackfill::JobOrchestrator.start_backfill(
        recruitment_cycle_year,
        dry_run:,
      )
    end
  end
end
