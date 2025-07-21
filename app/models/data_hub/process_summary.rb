module DataHub
  class ProcessSummary < ApplicationRecord
    self.table_name = "data_hub_process_summary"

    enum :status, {
      started: "started",
      finished: "finished",
      failed: "failed",
    }

    validates :status, :type, :started_at, presence: true

    def duration_in_seconds
      return unless started_at && finished_at

      finished_at - started_at
    end
  end
end
