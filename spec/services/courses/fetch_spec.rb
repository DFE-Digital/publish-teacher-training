require "rails_helper"

describe Courses::Fetch do
  describe ".by_code" do
    let(:provider_code) { course.provider.provider_code }
    let(:course_code) { course.course_code }
    let(:recruitment_cycle_year) { course.recruitment_cycle.year }
    let(:course) { create(:course) }

    it "fetches a course by course_code" do
      expect(described_class.by_code(
        provider_code:,
        course_code:,
        recruitment_cycle_year:,
      )).to eq(course)
    end
  end
end
