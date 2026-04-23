# frozen_string_literal: true

require "rails_helper"

describe CourseSchools::Remover do
  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:) }
  let(:gias_school) { create(:gias_school) }

  it "destroys the Course::School row matching (course, gias_school)" do
    create(:course_school, course:, gias_school:, site_code: "A")

    expect {
      described_class.call(course:, gias_school_id: gias_school.id)
    }.to change(Course::School, :count).by(-1)
  end

  it "is a no-op when no matching Course::School exists" do
    expect {
      described_class.call(course:, gias_school_id: gias_school.id)
    }.not_to change(Course::School, :count)
  end

  it "does not touch Course::School rows for other (course, gias_school) pairs" do
    other_course = create(:course, provider:)
    other_gias = create(:gias_school)

    create(:course_school, course:, gias_school:, site_code: "A")
    create(:course_school, course: other_course, gias_school:, site_code: "A")
    create(:course_school, course:, gias_school: other_gias, site_code: "B")

    expect {
      described_class.call(course:, gias_school_id: gias_school.id)
    }.to change(Course::School, :count).by(-1)

    expect(Course::School.where(course:, gias_school:)).to be_empty
    expect(Course::School.where(course: other_course, gias_school:)).not_to be_empty
    expect(Course::School.where(course:, gias_school: other_gias)).not_to be_empty
  end
end
