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

  describe ".not_withdrawn" do
    it "returns only saved courses for courses that are not withdrawn" do
      included_saved_course = create(
        :saved_course,
        course: create(:course, :published, :with_full_time_sites),
      )
      create(
        :saved_course,
        course: create(:course, :withdrawn, :with_full_time_sites),
      )

      expect(described_class.not_withdrawn).to contain_exactly(included_saved_course)
    end

    it "removes duplicates caused by findable site status joins" do
      saved_course = create(
        :saved_course,
        course: create(:course, :published, :with_2_full_time_sites),
      )

      expect(described_class.not_withdrawn.where(id: saved_course.id).count).to eq(1)
    end
  end
end
