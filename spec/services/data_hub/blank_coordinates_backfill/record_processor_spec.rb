require "rails_helper"

RSpec.describe DataHub::BlankCoordinatesBackfill::RecordProcessor, type: :service do
  let(:process_summary) { create(:blank_coordinates_backfill_process_summary) }
  let(:site) { create(:site, latitude: nil, longitude: nil) }
  let(:geocoder) { DataHub::Geocoder::DryRun.new }

  before do
    process_summary.initialize_summary!(total_records: 1, batch_size: 40, dry_run: true)
  end

  describe "#call" do
    subject(:processor) do
      described_class.new(
        record_type: "Site",
        record_id: site.id,
        geocoder: geocoder,
        process_summary: process_summary,
      )
    end

    context "when geocoding succeeds" do
      it "records successful result in process summary" do
        result = processor.call

        expect(result.success?).to be(true)
        expect(result.latitude).to be_present
        expect(result.longitude).to be_present

        process_summary.reload
        expect(process_summary.records_backfilled).to eq(1)
        expect(process_summary.records_failed).to eq(0)
      end

      it "stores before and after coordinates" do
        site.update!(latitude: 50.0, longitude: -1.0)

        processor.call

        processed = process_summary.reload.full_summary["records_processed"].first
        expect(processed["previous_latitude"]).to eq(50.0)
        expect(processed["previous_longitude"]).to eq(-1.0)
        expect(processed["new_latitude"]).to be_present
        expect(processed["new_longitude"]).to be_present
      end
    end

    context "when geocoding fails" do
      let(:geocoder) do
        instance_double(DataHub::Geocoder::Real).tap do |g|
          allow(g).to receive(:geocode).and_return(
            DataHub::Geocoder::Result.new(
              success: false,
              latitude: nil,
              longitude: nil,
              error_message: "API rate limit exceeded",
            ),
          )
        end
      end

      it "records failure in process summary" do
        result = processor.call

        expect(result.success?).to be(false)
        expect(result.error_message).to eq("API rate limit exceeded")

        process_summary.reload
        expect(process_summary.records_backfilled).to eq(0)
        expect(process_summary.records_failed).to eq(1)
        expect(process_summary.short_summary["failed_records"].first["error"]).to include("rate limit")
      end
    end

    context "when record does not exist" do
      subject(:processor) do
        described_class.new(
          record_type: "Site",
          record_id: 999_999,
          geocoder: geocoder,
          process_summary: process_summary,
        )
      end

      it "returns nil without updating summary" do
        result = processor.call

        expect(result).to be_nil
        expect(process_summary.reload.records_backfilled).to eq(0)
        expect(process_summary.records_failed).to eq(0)
      end
    end

    context "when processing raises an error" do
      before do
        allow(geocoder).to receive(:geocode).and_raise(StandardError, "Unexpected error")
      end

      it "handles error and records it in summary" do
        result = processor.call

        expect(result.success?).to be(false)
        expect(result.error_message).to include("Unexpected error")

        process_summary.reload
        expect(process_summary.records_failed).to eq(1)
      end
    end

    context "with GiasSchool record type" do
      subject(:processor) do
        described_class.new(
          record_type: "GiasSchool",
          record_id: gias_school.id,
          geocoder: geocoder,
          process_summary: process_summary,
        )
      end

      let(:gias_school) { create(:gias_school, latitude: nil, longitude: nil) }

      it "processes GiasSchool records correctly" do
        result = processor.call

        expect(result.success?).to be(true)

        processed = process_summary.reload.full_summary["records_processed"].first
        expect(processed["record_type"]).to eq("GiasSchool")
        expect(processed["record_id"]).to eq(gias_school.id)
      end
    end
  end
end
