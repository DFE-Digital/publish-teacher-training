module DataHub
  class ProcessSummary < ApplicationRecord
    self.table_name = "data_hub_process_summary"

    enum :status, {
      started: "started",
      finished: "finished",
      failed: "failed",
    }

    validates :status, :type, :started_at, presence: true

    def self.start!
      create!(
        started_at: Time.current,
        status: :started,
        short_summary: {},
        full_summary: {},
      )
    end

    def finish!(short_summary:, full_summary:)
      update!(
        finished_at: Time.current,
        status: :finished,
        short_summary: short_summary,
        full_summary: full_summary,
      )
    end

    def fail!(error)
      update!(
        finished_at: Time.current,
        status: :failed,
        short_summary: {
          error_class: error.class.to_s,
          error_message: error.message,
          backtrace: error.backtrace&.take(10),
        },
      )
    end

    def duration_in_seconds
      return unless started_at && finished_at

      finished_at - started_at
    end
  end
end
