module DataHub
  module BlankCoordinatesBackfill
    class RecordProcessor
      attr_reader :record_type, :record_id, :record, :geocoder, :process_summary

      def initialize(record_type:, record_id:, geocoder:, process_summary:)
        @record_type = record_type
        @record_id = record_id
        @geocoder = geocoder
        @process_summary = process_summary
        @record = @record_type.constantize.find_by(id: @record_id)
      end

      def call
        return if @record.blank?

        previous_latitude = @record.latitude
        previous_longitude = @record.longitude

        result = geocoder.geocode(record)

        log_result(result)

        process_summary.add_backfill_result(
          record_type: record_type,
          record_id: record_id,
          result: result,
          previous_latitude: previous_latitude,
          previous_longitude: previous_longitude,
        )

        result
      rescue StandardError => e
        handle_error(e)
      end

    private

      def log_result(result)
        if result.success?
          Log.info("✓ #{record_type} ##{record_id} geocoded: (#{result.latitude}, #{result.longitude})")
        else
          Log.warn("✗ #{record_type} ##{record_id} failed: #{result.error_message}")
        end
      end

      def handle_error(error)
        Log.error("Error processing #{record_type} ##{record_id}: #{error.class}: #{error.message}")

        error_result = DataHub::Geocoder::Result.new(
          success: false,
          latitude: nil,
          longitude: nil,
          error_message: "Processing error: #{error.class}: #{error.message}",
        )

        process_summary.add_backfill_result(
          record_type: record_type,
          record_id: record_id,
          result: error_result,
          previous_latitude: record.latitude,
          previous_longitude: record.longitude,
        )

        error_result
      end
    end
  end
end
