# == Schema Information
#
# Table name: course
#
#  id                      :integer          not null, primary key
#  age_range               :text
#  course_code             :text
#  name                    :text
#  profpost_flag           :text
#  program_type            :text
#  qualification           :integer          not null
#  start_date              :datetime
#  study_mode              :text
#  accrediting_provider_id :integer
#  provider_id             :integer          default(0), not null
#  modular                 :text
#  english                 :integer
#  maths                   :integer
#  science                 :integer
#

class CourseSummarySerializer < ActiveModel::Serializer
  has_one :provider, serializer: CourseProviderSerializer
  has_one :accrediting_provider, serializer: CourseProviderSerializer

  attributes :course_code, :start_date, :name, :study_mode, :profpost_flag,
             :findable?, :can_be_applied_to?
end
