require "rails_helper"

RSpec.describe DataHub::BlankCoordinatesBackfill::MonitoringManager, type: :service do
  let(:process_summary) { create(:blank_coordinates_backfill_process_summary) }

  before do
    process_summary.initialize_summary!(total_records: 5, batch_size: 40, dry_run: false)
  end

  describe ".check_completion" do
    context "when all records are processed successfully" do
      before do
        5.times do |i|
          result = DataHub::Geocoder::Result.new(success: true, latitude: 51.5, longitude: -0.1)
          process_summary.add_backfill_result(
            record_type: "Site",
            record_id: i + 1,
            result: result,
            previous_latitude: nil,
            previous_longitude: nil,
          )
        end
      end

      it "finishes the process successfully" do
        described_class.check_completion(process_summary.id, 1)

        process_summary.reload
        expect(process_summary.status).to eq("finished")
        expect(process_summary.finished_at).to be_present
      end

      it "does not schedule another monitoring check" do
        expect(BlankCoordinatesBackfill::MonitoringJob).not_to receive(:set)
        described_class.check_completion(process_summary.id, 1)
      end
    end

    context "when some records are still processing" do
      before do
        2.times do |i|
          result = DataHub::Geocoder::Result.new(success: true, latitude: 51.5, longitude: -0.1)
          process_summary.add_backfill_result(
            record_type: "Site",
            record_id: i + 1,
            result: result,
            previous_latitude: nil,
            previous_longitude: nil,
          )
        end
      end

      it "schedules next monitoring check when under attempt limit" do
        allow(BlankCoordinatesBackfill::MonitoringJob).to receive(:set).and_return(BlankCoordinatesBackfill::MonitoringJob)
        allow(BlankCoordinatesBackfill::MonitoringJob).to receive(:perform_later)

        described_class.check_completion(process_summary.id, 1)

        expect(BlankCoordinatesBackfill::MonitoringJob).to have_received(:set).with(wait: 5.minutes)
        expect(BlankCoordinatesBackfill::MonitoringJob).to have_received(:perform_later).with(process_summary.id, 2)

        process_summary.reload
        expect(process_summary.status).to eq("started")
      end

      it "handles timeout when max attempts reached" do
        expect(BlankCoordinatesBackfill::MonitoringJob).not_to receive(:set)

        described_class.check_completion(process_summary.id, 5)

        process_summary.reload
        expect(process_summary.status).to eq("finished")
        expect(process_summary.full_summary["monitoring_timeout"]).to be_present
        expect(process_summary.full_summary["monitoring_timeout"]["warning"]).to include("timeout")
      end
    end

    context "when process is already finished" do
      before do
        process_summary.update!(status: "finished", finished_at: Time.current)
      end

      it "does not process further or schedule monitoring" do
        expect(BlankCoordinatesBackfill::MonitoringJob).not_to receive(:set)

        described_class.check_completion(process_summary.id, 1)

        # Status should remain unchanged
        expect(process_summary.reload.status).to eq("finished")
      end
    end

    context "when process has failed" do
      before do
        process_summary.update!(status: "failed", finished_at: Time.current)
      end

      it "does not process further" do
        expect(BlankCoordinatesBackfill::MonitoringJob).not_to receive(:set)

        described_class.check_completion(process_summary.id, 1)
      end
    end

    context "with mixed success and failures" do
      before do
        3.times do |i|
          result = DataHub::Geocoder::Result.new(success: true, latitude: 51.5, longitude: -0.1)
          process_summary.add_backfill_result(
            record_type: "Site",
            record_id: i + 1,
            result: result,
            previous_latitude: nil,
            previous_longitude: nil,
          )
        end

        2.times do |i|
          result = DataHub::Geocoder::Result.new(success: false, latitude: nil, longitude: nil, error_message: "API error")
          process_summary.add_backfill_result(
            record_type: "Site",
            record_id: i + 4,
            result: result,
            previous_latitude: nil,
            previous_longitude: nil,
          )
        end
      end

      it "finishes when all records processed regardless of success/failure" do
        described_class.check_completion(process_summary.id, 1)

        process_summary.reload
        expect(process_summary.status).to eq("finished")
        expect(process_summary.records_backfilled).to eq(3)
        expect(process_summary.records_failed).to eq(2)
      end
    end
  end
end
