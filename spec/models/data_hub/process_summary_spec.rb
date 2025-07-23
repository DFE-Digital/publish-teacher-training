require "rails_helper"

RSpec.describe DataHub::ProcessSummary, type: :model do
  subject(:summary) { build(:register_school_import_summary) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:status) }

    it "is invalid with an unknown status" do
      expect {
        described_class.new(status: "invalid")
      }.to raise_error(ArgumentError, /'invalid' is not a valid status/)
    end
  end

  describe "enums" do
    it "defines expected values" do
      expect(described_class.statuses).to eq(
        "started" => "started",
        "finished" => "finished",
        "failed" => "failed",
      )
    end

    context "when the status is failed" do
      subject { build(:register_school_import_summary, status: :failed) }

      it { is_expected.to be_failed }
      it { is_expected.not_to be_finished }
      it { is_expected.not_to be_started }
    end
  end

  describe "#duration_in_seconds" do
    context "when finished_at is set" do
      subject do
        build(:register_school_import_summary, started_at:, finished_at:)
      end

      let(:started_at)  { Time.current }
      let(:finished_at) { started_at + 92.seconds }

      it "returns the difference in seconds" do
        expect(subject.duration_in_seconds).to eq(92)
      end
    end

    context "when finished_at is nil" do
      subject do
        build(:register_school_import_summary, started_at: Time.current, finished_at: nil)
      end

      it "returns nil" do
        expect(subject.duration_in_seconds).to be_nil
      end
    end
  end

  describe "STI subclass" do
    subject(:persisted_summary) { create(:register_school_import_summary) }

    it "does not raise" do
      expect(persisted_summary).to be_persisted
    end

    it "is a RegisterSchoolImportSummary" do
      expect(persisted_summary).to be_a(DataHub::RegisterSchoolImportSummary)
    end

    it "can be found via ProcessSummary" do
      found = described_class.find(persisted_summary.id)
      expect(found).to be_a(DataHub::RegisterSchoolImportSummary)
    end
  end

  describe ".start!" do
    it "creates a new summary with status 'started' and timestamps" do
      summary = DataHub::RegisterSchoolImportSummary.start!

      expect(summary).to be_started
      expect(summary.started_at).to be_within(1.second).of(Time.current)
      expect(summary.status).to eq("started")
      expect(summary.short_summary).to eq({})
      expect(summary.full_summary).to eq({})
      expect(summary.type).to eq("DataHub::RegisterSchoolImportSummary")
    end
  end

  describe "#finish!" do
    let(:summary) { create(:process_summary) }

    it "updates status to 'finished' and fills summary fields" do
      short_summary = { count: 42 }
      full_summary = { sites: [1, 2, 3] }

      summary.finish!(short_summary:, full_summary:)

      expect(summary.status).to eq("finished")
      expect(summary.finished_at).to be_within(1.second).of(Time.current)
      expect(summary.short_summary).to eq(short_summary.stringify_keys)
      expect(summary.full_summary).to eq(full_summary.stringify_keys)
    end
  end

  describe "#fail!" do
    let(:summary) { create(:process_summary) }
    let(:error) { StandardError.new("Something went wrong") }

    it "updates status to 'failed' with error details" do
      summary.fail!(error)

      expect(summary.status).to eq("failed")
      expect(summary.finished_at).to be_within(1.second).of(Time.current)
      expect(summary.short_summary["error_class"]).to eq("StandardError")
      expect(summary.short_summary["error_message"]).to eq("Something went wrong")
    end
  end
end
