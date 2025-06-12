require "rails_helper"

RSpec.describe SavedCourse, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:candidate) }
    it { is_expected.to belong_to(:course) }
  end

  describe "validations" do
    subject { create(:saved_course) }

    it { is_expected.to validate_uniqueness_of(:candidate_id).scoped_to(:course_id) }
  end
end
