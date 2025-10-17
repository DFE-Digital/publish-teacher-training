module BlankCoordinatesBackfill
  class BatchJob < ApplicationJob
    queue_as :geocoding
    retry_on StandardError, attempts: 0

    def perform(records_batch, process_summary_id, dry_run)
      DataHub::BlankCoordinatesBackfill::Log.info("BatchJob starting: process_summary=#{process_summary_id}, records=#{records_batch.size}, dry_run=#{dry_run}")

      process_summary = DataHub::BlankCoordinatesBackfillProcessSummary.find(process_summary_id)
      geocoder = dry_run ? DataHub::Geocoder::DryRun.new : DataHub::Geocoder::Real.new

      records_batch.each do |record_data|
        DataHub::BlankCoordinatesBackfill::RecordProcessor.new(
          record_type: record_data[:type],
          record_id: record_data[:id],
          geocoder:,
          process_summary:,
        ).call
      end

      DataHub::BlankCoordinatesBackfill::Log.info("BatchJob finished: process_summary=#{process_summary_id}, processed=#{records_batch.size} records")
    end
  end
end
