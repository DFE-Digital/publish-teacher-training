module BlankCoordinatesBackfill
  class MonitoringJob < ApplicationJob
    self.queue_adapter = :solid_queue
    queue_as :default
    without_auto_retry

    def perform(process_summary_id, attempt_number)
      DataHub::BlankCoordinatesBackfill::MonitoringManager.check_completion(process_summary_id, attempt_number)
    end
  end
end
