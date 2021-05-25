require "rails_helper"

describe RecruitmentCycleCreationService do
  describe ".call" do
    subject { described_class.call(year: 2030, application_start_date: "2031-09-01", application_end_date: "2032-09-01") }

    it "calls the recruitment cycle creation service" do
      expect(RecruitmentCycleCreationService).to receive(:call)
      subject
    end

    it "returns nil" do
      expect(subject).to be(nil)
    end
  end
end
