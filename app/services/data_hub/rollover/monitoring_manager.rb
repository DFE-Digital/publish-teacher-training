# frozen_string_literal: true

module DataHub
  module Rollover
    class MonitoringManager
      MAX_ATTEMPTS = 5
      CHECK_INTERVAL = 5.minutes

      attr_reader :process_summary

      delegate :all_providers_processed?, :already_finished?, to: :process_summary

      def self.check_completion(process_summary_id, attempt_number = 1)
        new(process_summary_id, attempt_number).execute
      end

      def initialize(process_summary_id, attempt_number)
        @process_summary_id = process_summary_id
        @attempt_number = attempt_number
      end

      def execute
        load_process_summary
        return if already_finished?

        RolloverLog.with_logging do
          log_monitoring_attempt

          if all_providers_processed?
            complete_process
          elsif should_continue_monitoring?
            schedule_next_check
          else
            handle_timeout
          end
        end
      end

    private

      attr_reader :process_summary_id, :attempt_number

      def load_process_summary
        @process_summary = RolloverProcessSummary.find(process_summary_id)
      end

      def log_monitoring_attempt
        total_processed = process_summary.total_processed
        total_providers = process_summary.short_summary["total_providers"]

        RolloverLog.info "Monitoring attempt #{attempt_number}/#{MAX_ATTEMPTS}: " \
                         "#{total_processed}/#{total_providers} providers processed " \
                         "(#{process_summary.completion_percentage}%)"
      end

      def complete_process
        process_summary.finish!(
          short_summary: process_summary.short_summary,
          full_summary: process_summary.full_summary,
        )

        total_processed = process_summary.total_processed
        total_providers = process_summary.short_summary["total_providers"]

        RolloverLog.info "Rollover process completed successfully. " \
                         "#{total_processed}/#{total_providers} providers processed"
      end

      def should_continue_monitoring?
        attempt_number < MAX_ATTEMPTS
      end

      def schedule_next_check
        next_attempt = attempt_number + 1
        RolloverMonitoringJob.perform_in(CHECK_INTERVAL, process_summary_id, next_attempt)

        RolloverLog.info "Scheduled next monitoring check (attempt #{next_attempt}) in #{CHECK_INTERVAL.to_i / 60} minutes"
      end

      def handle_timeout
        total_processed = process_summary.total_processed
        total_providers = process_summary.short_summary["total_providers"]

        RolloverLog.warn "Monitoring stopped after #{attempt_number} attempts. " \
                         "#{total_processed}/#{total_providers} providers processed. " \
                         "Some jobs may still be running or failed silently."

        finalize_with_timeout(total_processed, total_providers)
      end

      def finalize_with_timeout(total_processed, total_providers)
        enhanced_full_summary = process_summary.full_summary.dup
        enhanced_full_summary["monitoring_timeout"] = {
          "total_attempts" => attempt_number,
          "final_processed_count" => total_processed,
          "expected_total" => total_providers,
          "timeout_at" => Time.current.iso8601,
          "warning" => "Monitoring stopped due to timeout. Some jobs may still be running.",
        }

        process_summary.finish!(
          short_summary: process_summary.short_summary,
          full_summary: enhanced_full_summary,
        )
      end
    end
  end
end
