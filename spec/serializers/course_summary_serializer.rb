require "rails_helper"

RSpec.describe CourseSummarySerializer do
  let!(:course) { create :course }
  subject { serialize(course) }

  it { should include(course_code: course.course_code) }
  it { should include(qualification: course.qualification) }
  it { should include(study_mode: course.study_mode) }
  it { should include(profpost_flag: course.profpost_flag) }
end
