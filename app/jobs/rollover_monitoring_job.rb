# frozen_string_literal: true

class RolloverMonitoringJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 0

  def perform(process_summary_id, attempt_number = 1)
    DataHub::Rollover::MonitoringManager.check_completion(process_summary_id, attempt_number)
  end
end
