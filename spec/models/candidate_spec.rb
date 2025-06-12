require "rails_helper"

RSpec.describe Candidate, type: :model do
  describe "validates email_address" do
    it "validates email_address" do
      candidate = build(:candidate, email_address: "bademail")
      candidate.validate

      expect(candidate.errors.full_messages).to include("Email address Enter an email address in the correct format, like name@example.com")
    end

    it "normalizes the users email address" do
      email_address = "  withpaddingANDuppercase@email.com"
      candidate = build(:candidate, email_address:)
      candidate.save

      expect(candidate.reload.email_address).to eq("withpaddinganduppercase@email.com")
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:saved_courses).dependent(:destroy) }
    it { is_expected.to have_many(:saved_course_records).through(:saved_courses).source(:course) }

    it "can have many saved courses through saved_course_records" do
      candidate = create(:candidate)

      course1 = create(:course)
      course2 = create(:course)

      create(:saved_course, candidate:, course: course1)
      create(:saved_course, candidate:, course: course2)

      expect(candidate.saved_courses.count).to eq(2)
      expect(candidate.saved_course_records).to contain_exactly(course1, course2)
    end

    it "destroys associated saved_courses when the candidate is destroyed" do
      candidate = create(:candidate)
      course = create(:course)

      create(:saved_course, candidate:, course:)

      expect {
        candidate.destroy
      }.to change(SavedCourse, :count).by(-1)
    end
  end
end
