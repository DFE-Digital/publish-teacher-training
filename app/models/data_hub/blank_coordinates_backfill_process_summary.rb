module DataHub
  class BlankCoordinatesBackfillProcessSummary < DataHub::ProcessSummary
    def initialize_summary!(total_records:, batch_size:, dry_run:)
      update!(
        short_summary: {
          dry_run:,
          total_records:,
          records_backfilled: 0,
          records_failed: 0,
          failed_records: [],
          batches_scheduled: 0,
          batch_size:,
        },
        full_summary: {
          dry_run:,
          batch_size:,
          backfill_started_at: Time.current.iso8601,
          batches: [],
          records_processed: [],
        },
      )
    end

    def add_batch_enqueue_info(batch_number:, scheduled_at:, records_count:)
      with_lock do
        current_full = full_summary.deep_symbolize_keys

        current_full[:batches] ||= []
        current_full[:batches] << {
          batch_number: batch_number,
          scheduled_at: scheduled_at.iso8601,
          records_count: records_count,
        }

        update!(full_summary: current_full)
      end
    end

    def add_backfill_result(record_type:, record_id:, result:, previous_latitude:, previous_longitude:)
      with_lock do
        current_short = short_summary.deep_symbolize_keys
        current_full = full_summary.deep_symbolize_keys

        # Safe defaults before operations
        current_short[:records_backfilled] ||= 0
        current_short[:records_failed] ||= 0
        current_short[:failed_records] ||= []
        current_full[:records_processed] ||= []

        if result.success?
          current_short[:records_backfilled] += 1
        else
          current_short[:records_failed] += 1
          current_short[:failed_records] << {
            record_type: record_type,
            record_id: record_id,
            error: result.error_message,
          }
        end

        current_full[:records_processed] << {
          record_type: record_type,
          record_id: record_id,
          success: result.success?,
          previous_latitude: previous_latitude,
          previous_longitude: previous_longitude,
          new_latitude: result.latitude,
          new_longitude: result.longitude,
          error_message: result.error_message,
          timestamp: Time.current.iso8601,
        }

        update!(short_summary: current_short, full_summary: current_full)
      end
    end

    def completion_percentage
      return 0 if total_records.zero?

      ((records_backfilled + records_failed).to_f / total_records * 100).round(2)
    end

    def success_rate
      total_processed = records_backfilled + records_failed
      return 0 if total_processed.zero?

      (records_backfilled.to_f / total_processed * 100).round(2)
    end

    def total_records
      short_summary["total_records"] || 0
    end

    def records_backfilled
      short_summary["records_backfilled"] || 0
    end

    def records_failed
      short_summary["records_failed"] || 0
    end

    def dry_run?
      short_summary["dry_run"] == true
    end

    def all_records_processed?
      records_backfilled + records_failed >= total_records
    end

    def already_finished?
      finished? || failed?
    end
  end
end
