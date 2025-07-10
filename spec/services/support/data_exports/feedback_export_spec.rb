require "rails_helper"

RSpec.describe Support::DataExports::FeedbackExport do
  subject { described_class.new }

  context "columns" do
    it "returns expected type" do
      expect(subject.type).to eql("feedback")
    end

    it "returns expected headers" do
      expect(subject.headers).to eql(["ID", "Ease of use", "User experience", "Created at"])
    end
  end

  describe "#to_csv" do
    let!(:feedback) { create(:feedback, id: 1, ease_of_use: "easy", experience: "Great", created_at: Time.zone.parse("2025-07-10")) }

    it "generates CSV with headers and data" do
      csv = subject.to_csv
      expect(csv).to include("ID,Ease of use,User experience,Created at")
      expect(csv).to include("1")
      expect(csv).to include("easy")
      expect(csv).to include("Great")
      expect(csv).to include("2025-07-10")
    end
  end

  describe "#filename" do
    it "returns a filename with the current date" do
      expected_filename = "feedbacks-#{Time.zone.now.strftime('%Y-%m-%d')}.csv"
      expect(subject.filename).to eql(expected_filename)
    end
  end

  describe "#data" do
    let!(:feedback_one) { create(:feedback, id: 1, ease_of_use: "easy", experience: "Great", created_at: 2.days.ago) }
    let!(:feedback_two) { create(:feedback, id: 2, ease_of_use: "difficult", experience: "Poor", created_at: 1.day.ago) }

    it "returns an array of feedback data" do
      data = subject.data
      expect(data).to eql([
        {
          "ID" => feedback_one.id,
          "Ease of use" => feedback_one.ease_of_use,
          "User experience" => feedback_one.experience,
          "Created at" => feedback_one.created_at,
        },
        {
          "ID" => feedback_two.id,
          "Ease of use" => feedback_two.ease_of_use,
          "User experience" => feedback_two.experience,
          "Created at" => feedback_two.created_at,
        },
      ])
    end
  end
end
