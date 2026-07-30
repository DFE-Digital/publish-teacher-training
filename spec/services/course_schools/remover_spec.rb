# frozen_string_literal: true

require "rails_helper"

describe CourseSchools::Remover do
  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:) }
  let(:gias_school) { create(:gias_school) }
  let(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: "A") }

  it "destroys the Course::School row matching (course, provider_school)" do
    create(:course_school, course:, gias_school:, provider_school:)

    expect {
      described_class.call(course:, provider_school:)
    }.to change(Course::School, :count).by(-1)
  end

  it "is a no-op when no matching Course::School exists" do
    expect {
      described_class.call(course:, provider_school:)
    }.not_to change(Course::School, :count)
  end

  it "does not touch rows for other courses or other provider_schools" do
    other_course = create(:course, provider:)
    other_gias = create(:gias_school)
    other_provider_school = create(:provider_school, provider:, gias_school: other_gias, site_code: "B")

    create(:course_school, course:, gias_school:, provider_school:)
    create(:course_school, course: other_course, gias_school:, provider_school:)
    create(:course_school, course:, gias_school: other_gias, provider_school: other_provider_school)

    expect {
      described_class.call(course:, provider_school:)
    }.to change(Course::School, :count).by(-1)

    expect(Course::School.where(course:, provider_school:)).to be_empty
    expect(Course::School.where(course: other_course, provider_school:)).not_to be_empty
    expect(Course::School.where(course:, provider_school: other_provider_school)).not_to be_empty
  end

  # Keying on gias_school_id used to destroy_all both rows here.
  context "when the provider holds the same gias_school under two site_codes" do
    let!(:other_provider_school) do
      create(:provider_school, provider:, gias_school:, site_code: "R")
    end

    it "detaches only the provider_school it was given" do
      create(:course_school, course:, gias_school:, provider_school:)
      create(:course_school, course:, gias_school:, provider_school: other_provider_school)

      expect {
        described_class.call(course:, provider_school:)
      }.to change(Course::School, :count).by(-1)

      expect(course.schools.reload.map(&:provider_school)).to contain_exactly(other_provider_school)
    end
  end
end
