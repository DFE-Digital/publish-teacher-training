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
end
