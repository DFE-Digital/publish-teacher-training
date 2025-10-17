require "rails_helper"

RSpec.describe DataHub::BlankCoordinatesBackfillProcessSummary, type: :model do
  let(:summary) { create(:blank_coordinates_backfill_process_summary) }

  describe "#initialize_summary!" do
    it "initializes with correct default values" do
      summary.initialize_summary!(total_records: 100, batch_size: 40, dry_run: false)

      expect(summary.total_records).to eq(100)
      expect(summary.records_backfilled).to eq(0)
      expect(summary.records_failed).to eq(0)
      expect(summary.short_summary["batch_size"]).to eq(40)
      expect(summary.dry_run?).to be(false)
    end

    context "with dry_run: true" do
      it "marks summary as dry run" do
        summary.initialize_summary!(total_records: 50, batch_size: 40, dry_run: true)

        expect(summary.dry_run?).to be(true)
      end
    end
  end

  describe "#add_batch_enqueue_info" do
    before do
      summary.initialize_summary!(total_records: 10, batch_size: 40, dry_run: false)
    end

    it "records batch scheduling information" do
      scheduled_time = Time.current + 10.seconds

      summary.add_batch_enqueue_info(
        batch_number: 1,
        scheduled_at: scheduled_time,
        records_count: 40,
      )

      batches = summary.reload.full_summary["batches"]
      expect(batches.size).to eq(1)
      expect(batches.first["batch_number"]).to eq(1)
      expect(batches.first["records_count"]).to eq(40)
    end

    it "appends multiple batches" do
      2.times do |i|
        summary.add_batch_enqueue_info(
          batch_number: i + 1,
          scheduled_at: Time.current + (i * 10).seconds,
          records_count: 40,
        )
      end

      expect(summary.reload.full_summary["batches"].size).to eq(2)
    end
  end

  describe "#add_backfill_result" do
    before do
      summary.initialize_summary!(total_records: 10, batch_size: 40, dry_run: false)
    end

    context "with successful result" do
      let(:result) do
        DataHub::Geocoder::Result.new(
          success: true,
          latitude: 51.5034,
          longitude: -0.1276,
        )
      end

      it "increments backfilled count" do
        expect {
          summary.add_backfill_result(
            record_type: "Site",
            record_id: 123,
            result: result,
            previous_latitude: nil,
            previous_longitude: nil,
          )
        }.to change { summary.reload.records_backfilled }.from(0).to(1)
      end

      it "records result details in full summary" do
        summary.add_backfill_result(
          record_type: "Site",
          record_id: 123,
          result: result,
          previous_latitude: 50.0,
          previous_longitude: -1.0,
        )

        processed = summary.reload.full_summary["records_processed"].first
        expect(processed["success"]).to be(true)
        expect(processed["record_type"]).to eq("Site")
        expect(processed["record_id"]).to eq(123)
        expect(processed["previous_latitude"]).to eq(50.0)
        expect(processed["new_latitude"]).to eq(51.5034)
      end
    end

    context "with failed result" do
      let(:result) do
        DataHub::Geocoder::Result.new(
          success: false,
          latitude: nil,
          longitude: nil,
          error_message: "API error",
        )
      end

      it "increments failed count" do
        expect {
          summary.add_backfill_result(
            record_type: "Site",
            record_id: 456,
            result: result,
            previous_latitude: nil,
            previous_longitude: nil,
          )
        }.to change { summary.reload.records_failed }.from(0).to(1)
      end

      it "adds to failed_records list" do
        summary.add_backfill_result(
          record_type: "Site",
          record_id: 456,
          result: result,
          previous_latitude: nil,
          previous_longitude: nil,
        )

        failed = summary.reload.short_summary["failed_records"].first
        expect(failed["record_type"]).to eq("Site")
        expect(failed["record_id"]).to eq(456)
        expect(failed["error"]).to eq("API error")
      end
    end
  end

  describe "#completion_percentage" do
    before do
      summary.initialize_summary!(total_records: 100, batch_size: 40, dry_run: false)
    end

    it "calculates percentage based on processed records" do
      result = DataHub::Geocoder::Result.new(success: true, latitude: 51.5, longitude: -0.1)

      25.times do |i|
        summary.add_backfill_result(
          record_type: "Site",
          record_id: i,
          result: result,
          previous_latitude: nil,
          previous_longitude: nil,
        )
      end

      expect(summary.completion_percentage).to eq(25.0)
    end

    context "when no records processed" do
      it "returns 0" do
        expect(summary.completion_percentage).to eq(0.0)
      end
    end
  end

  describe "#success_rate" do
    before do
      summary.initialize_summary!(total_records: 100, batch_size: 40, dry_run: false)
    end

    it "calculates success rate correctly" do
      success_result = DataHub::Geocoder::Result.new(success: true, latitude: 51.5, longitude: -0.1)
      failure_result = DataHub::Geocoder::Result.new(success: false, latitude: nil, longitude: nil, error_message: "Error")

      8.times do |i|
        summary.add_backfill_result(
          record_type: "Site",
          record_id: i,
          result: success_result,
          previous_latitude: nil,
          previous_longitude: nil,
        )
      end

      2.times do |i|
        summary.add_backfill_result(
          record_type: "Site",
          record_id: i + 8,
          result: failure_result,
          previous_latitude: nil,
          previous_longitude: nil,
        )
      end

      expect(summary.reload.success_rate).to eq(80.0) # 8/10 = 80%
    end

    context "when no records processed" do
      it "returns 0" do
        expect(summary.success_rate).to eq(0.0)
      end
    end
  end

  describe "#all_records_processed?" do
    before do
      summary.initialize_summary!(total_records: 5, batch_size: 40, dry_run: false)
    end

    it "returns true when all records are processed" do
      result = DataHub::Geocoder::Result.new(success: true, latitude: 51.5, longitude: -0.1)

      5.times do |i|
        summary.add_backfill_result(
          record_type: "Site",
          record_id: i,
          result: result,
          previous_latitude: nil,
          previous_longitude: nil,
        )
      end

      expect(summary.reload.all_records_processed?).to be(true)
    end

    it "returns false when records remain" do
      result = DataHub::Geocoder::Result.new(success: true, latitude: 51.5, longitude: -0.1)

      summary.add_backfill_result(
        record_type: "Site",
        record_id: 1,
        result: result,
        previous_latitude: nil,
        previous_longitude: nil,
      )

      expect(summary.reload.all_records_processed?).to be(false)
    end
  end

  describe "#already_finished?" do
    it "returns true when status is finished" do
      summary.update!(status: "finished")
      expect(summary.already_finished?).to be(true)
    end

    it "returns true when status is failed" do
      summary.update!(status: "failed")
      expect(summary.already_finished?).to be(true)
    end

    it "returns false when status is started" do
      summary.update!(status: "started")
      expect(summary.already_finished?).to be(false)
    end
  end
end
