# == Schema Information
#
# Table name: course
#
#  id                        :integer          not null, primary key
#  age_range                 :text
#  course_code               :text
#  name                      :text
#  profpost_flag             :text
#  program_type              :text
#  qualification             :integer          not null
#  start_date                :datetime
#  study_mode                :text
#  accrediting_provider_id   :integer
#  provider_id               :integer          default(0), not null
#  modular                   :text
#  english                   :integer
#  maths                     :integer
#  science                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  changed_at                :datetime         not null
#  accrediting_provider_code :text
#  discarded_at              :datetime
#  age_range_in_years        :string
#

require "rails_helper"

RSpec.describe CourseSerializer do
  let(:course) { create :course, provider: provider }
  let(:provider) { build(:provider) }
  subject { serialize(course) }

  it { should include(course_code: course.course_code) }
  it { should include(name: course.name) }
  it { should include(recruitment_cycle: course.provider.recruitment_cycle.year) }
end
