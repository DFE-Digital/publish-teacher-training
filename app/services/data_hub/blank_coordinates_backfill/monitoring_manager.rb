module DataHub
  module BlankCoordinatesBackfill
    class MonitoringManager
      MAX_ATTEMPTS = 5
      CHECK_INTERVAL = 5.minutes

      attr_reader :process_summary, :process_summary_id, :attempt_number

      delegate :all_records_processed?, :already_finished?, to: :process_summary

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

        Log.with_logging do
          log_monitoring_attempt

          if all_records_processed?
            complete_process
          elsif should_continue_monitoring?
            schedule_next_check
          else
            handle_timeout
          end
        end
      end

    private

      def load_process_summary
        @process_summary = ProcessSummary.find(process_summary_id)
      end

      def log_monitoring_attempt
        total_processed = process_summary.records_backfilled + process_summary.records_failed
        total_records = process_summary.total_records

        Log.info("Monitoring attempt #{attempt_number}/#{MAX_ATTEMPTS}: " \
                 "#{total_processed}/#{total_records} records processed " \
                 "(#{process_summary.completion_percentage}%)")
      end

      def complete_process
        process_summary.finish!(
          short_summary: process_summary.short_summary,
          full_summary: process_summary.full_summary,
        )

        total_processed = process_summary.records_backfilled + process_summary.records_failed
        total_records = process_summary.total_records

        Log.info("Backfill process completed successfully. " \
                 "#{total_processed}/#{total_records} records processed. " \
                 "Success rate: #{process_summary.success_rate}%")
      end

      def should_continue_monitoring?
        attempt_number < MAX_ATTEMPTS
      end

      def schedule_next_check
        next_attempt = attempt_number + 1

        ::BlankCoordinatesBackfill::MonitoringJob.set(wait: CHECK_INTERVAL).perform_later(
          process_summary_id,
          next_attempt,
        )

        Log.info("Scheduled next monitoring check (attempt #{next_attempt}) in #{CHECK_INTERVAL.to_i / 60} minutes")
      end

      def handle_timeout
        total_processed = process_summary.records_backfilled + process_summary.records_failed
        total_records = process_summary.total_records

        Log.warn("Monitoring stopped after #{attempt_number} attempts. " \
                 "#{total_processed}/#{total_records} records processed. " \
                 "Some jobs may still be running or failed silently.")

        finalize_with_timeout(total_processed, total_records)
      end

      def finalize_with_timeout(total_processed, total_records)
        enhanced_full_summary = process_summary.full_summary.dup
        enhanced_full_summary["monitoring_timeout"] = {
          "total_attempts" => attempt_number,
          "final_processed_count" => total_processed,
          "expected_total" => total_records,
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
