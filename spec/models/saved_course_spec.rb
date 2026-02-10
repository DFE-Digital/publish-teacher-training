require "rails_helper"

RSpec.describe SavedCourse, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:candidate) }
    it { is_expected.to belong_to(:course) }
  end

  describe "validations" do
    subject { create(:saved_course) }

    it { is_expected.to validate_uniqueness_of(:candidate_id).scoped_to(:course_id) }

    it "allows note to be nil" do
      saved_course = build(:saved_course, note: nil)
      expect(saved_course).to be_valid
    end

    it "allows up to 100 words in note" do
      saved_course = build(:saved_course, note: ("word " * 100).strip)

      expect(saved_course).to be_valid
    end

    it "does not allow more than 100 words in note" do
      saved_course = build(:saved_course, note: ("word " * 101).strip)

      expect(saved_course).not_to be_valid
      expect(saved_course.errors[:note]).to include("Your note must be 100 words or less")
    end
  end
end
