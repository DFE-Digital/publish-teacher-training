# frozen_string_literal: true

class RolloverMonitoringJob
  include Sidekiq::Job

  def perform(process_summary_id, attempt_number = 1)
    DataHub::Rollover::MonitoringManager.check_completion(process_summary_id, attempt_number)
  end
end
