require "rails_helper"

RSpec.describe CourseSerializer do
  let(:course) { create :course }
  subject { serialize(course) }

  it {
    is_expected.to include(course_code: course.course_code,
                              name: course.name,
                              qualification: course.qualification)
  }
end
