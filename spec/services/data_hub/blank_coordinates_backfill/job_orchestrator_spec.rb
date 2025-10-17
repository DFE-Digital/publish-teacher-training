require "rails_helper"

RSpec.describe DataHub::BlankCoordinatesBackfill::JobOrchestrator, type: :service do
  let(:recruitment_cycle) { RecruitmentCycle.current }
  let!(:sites_without_coordinates) do
    create_list(:site, 5, latitude: nil, longitude: nil, provider: create(:provider, recruitment_cycle:))
  end
  let!(:gias_schools_without_coordinates) do
    create_list(:gias_school, 3, latitude: nil, longitude: nil)
  end

  describe ".start_backfill" do
    subject(:start_backfill) { described_class.start_backfill(recruitment_cycle.year, dry_run: false) }

    it "creates a process summary with correct total records" do
      summary = start_backfill

      expect(summary).to be_a(DataHub::BlankCoordinatesBackfillProcessSummary)
      expect(summary.total_records).to eq(8) # 5 sites + 3 schools
      expect(summary.status).to eq("started")
    end

    it "initializes summary with correct metadata" do
      summary = start_backfill

      expect(summary.short_summary["dry_run"]).to be(false)
      expect(summary.short_summary["batch_size"]).to eq(40)
      expect(summary.short_summary["records_backfilled"]).to eq(0)
      expect(summary.short_summary["records_failed"]).to eq(0)
    end

    it "schedules batch jobs for all records" do
      allow(BlankCoordinatesBackfill::BatchJob).to receive(:set).and_return(BlankCoordinatesBackfill::BatchJob)
      allow(BlankCoordinatesBackfill::BatchJob).to receive(:perform_later)

      start_backfill

      expect(BlankCoordinatesBackfill::BatchJob).to have_received(:set).with(wait_until: kind_of(Time))
      expect(BlankCoordinatesBackfill::BatchJob).to have_received(:perform_later).with(
        kind_of(Array),
        kind_of(Integer),
        false,
      )
    end

    it "schedules monitoring job after batches" do
      allow(BlankCoordinatesBackfill::MonitoringJob).to receive(:set).and_return(BlankCoordinatesBackfill::MonitoringJob)
      allow(BlankCoordinatesBackfill::MonitoringJob).to receive(:perform_later)

      start_backfill

      expect(BlankCoordinatesBackfill::MonitoringJob).to have_received(:set).with(wait: kind_of(ActiveSupport::Duration))
      expect(BlankCoordinatesBackfill::MonitoringJob).to have_received(:perform_later).with(
        kind_of(Integer),
        1,
      )
    end

    it "records batch scheduling information in summary" do
      summary = start_backfill

      expect(summary.full_summary["batches"]).to be_present
      expect(summary.full_summary["batches"].size).to eq(1) # 8 records in 1 batch (batch_size=40)
      expect(summary.short_summary["batches_scheduled"]).to eq(1)
    end

    context "when there are no records needing backfill" do
      let!(:sites_without_coordinates) { [] }
      let!(:gias_schools_without_coordinates) { [] }

      it "returns nil without creating a process summary" do
        expect(start_backfill).to be_nil
        expect(DataHub::BlankCoordinatesBackfillProcessSummary.count).to eq(0)
      end
    end

    context "when there are more records than batch size" do
      before do
        stub_const("DataHub::BlankCoordinatesBackfill::JobOrchestrator::DEFAULT_BATCH_SIZE", 3)
      end

      it "schedules multiple batches with correct intervals" do
        summary = start_backfill

        batches = summary.full_summary["batches"]
        expect(batches.size).to eq(3) # 8 records / 3 per batch = 3 batches

        first_batch_time = Time.zone.parse(batches[0]["scheduled_at"])
        second_batch_time = Time.zone.parse(batches[1]["scheduled_at"])

        interval = (second_batch_time - first_batch_time).to_i
        expect(interval).to be >= 10 # MIN_SECONDS_BETWEEN_BATCHES
      end
    end

    context "with dry_run: true" do
      subject(:start_backfill) { described_class.start_backfill(recruitment_cycle.year, dry_run: true) }

      it "marks summary as dry run" do
        summary = start_backfill

        expect(summary.dry_run?).to be(true)
        expect(summary.short_summary["dry_run"]).to be(true)
      end

      it "passes dry_run flag to batch jobs" do
        allow(BlankCoordinatesBackfill::BatchJob).to receive(:set).and_return(BlankCoordinatesBackfill::BatchJob)
        allow(BlankCoordinatesBackfill::BatchJob).to receive(:perform_later)

        start_backfill

        expect(BlankCoordinatesBackfill::BatchJob).to have_received(:perform_later).with(
          anything,
          anything,
          true,
        )
      end
    end

    context "when orchestration fails" do
      let(:orchestrator) { described_class.new(recruitment_cycle.year) }

      before do
        allow(DataHub::BlankCoordinatesBackfill::Query).to receive(:new).and_return(
          instance_double(DataHub::BlankCoordinatesBackfill::Query, total_count: 8, call: []),
        )
        allow(orchestrator).to receive(:calculate_batch_schedule).and_raise(StandardError, "Database error")
      end

      it "marks process summary as failed and re-raises error" do
        expect { orchestrator.execute }.to raise_error(StandardError, "Database error")

        summary = DataHub::BlankCoordinatesBackfillProcessSummary.last
        expect(summary.status).to eq("failed")
        expect(summary.short_summary["error_message"]).to include("Database error")
      end
    end
  end

  describe "#calculate_batch_schedule" do
    let(:orchestrator) { described_class.new(recruitment_cycle.year) }

    before do
      stub_const("DataHub::BlankCoordinatesBackfill::JobOrchestrator::DEFAULT_BATCH_SIZE", 3)
      stub_const("DataHub::BlankCoordinatesBackfill::JobOrchestrator::MIN_SECONDS_BETWEEN_BATCHES", 10)
    end

    it "creates batches with increasing scheduled times" do
      batches_info = orchestrator.send(:calculate_batch_schedule)

      expect(batches_info.size).to eq(3)
      expect(batches_info[0][:at] < batches_info[1][:at]).to be(true)
      expect(batches_info[1][:at] < batches_info[2][:at]).to be(true)
    end

    it "spaces batches by at least minimum interval" do
      batches_info = orchestrator.send(:calculate_batch_schedule)

      interval = batches_info[1][:at] - batches_info[0][:at]
      expect(interval).to be >= 10
    end
  end
end
