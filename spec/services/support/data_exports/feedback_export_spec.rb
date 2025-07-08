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

  describe ".feedback_data" do
    let(:feedback) { build(:feedback, id: 1, ease_of_use: "easy", experience: "Great", created_at: 1.day.ago) }

    it "returns a hash of feedback attributes" do
      res = subject.send(:feedback_data, feedback)
      expect(res).to eql(
        {
          "ID" => feedback.id,
          "Ease of use" => feedback.ease_of_use,
          "User experience" => feedback.experience,
          "Created at" => feedback.created_at,
        },
      )
    end
  end

  describe ".data" do
    let!(:feedbackone) { create(:feedback, id: 1, ease_of_use: "easy", experience: "Great", created_at: 2.days.ago) }
    let!(:feedbacktwo) { create(:feedback, id: 2, ease_of_use: "difficult", experience: "Poor", created_at: 1.day.ago) }

    it "returns an array of feedback data" do
      res = subject.data
      expect(res).to eql([
        {
          "ID" => feedbackone.id,
          "Ease of use" => feedbackone.ease_of_use,
          "User experience" => feedbackone.experience,
          "Created at" => feedbackone.created_at,
        },
        {
          "ID" => feedbacktwo.id,
          "Ease of use" => feedbacktwo.ease_of_use,
          "User experience" => feedbacktwo.experience,
          "Created at" => feedbacktwo.created_at,
        },
      ])
    end
  end
end
