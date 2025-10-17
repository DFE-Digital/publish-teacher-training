module BlankCoordinatesBackfill
  class MonitoringJob < ApplicationJob
    queue_as :default
    retry_on StandardError, attempts: 0

    def perform(process_summary_id, attempt_number)
      DataHub::BlankCoordinatesBackfill::MonitoringManager.check_completion(process_summary_id, attempt_number)
    end
  end
end
