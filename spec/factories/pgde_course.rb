# == Schema Information
#
# Table name: pgde_course
#
#  id            :integer          not null, primary key
#  course_code   :text             not null
#  provider_code :text             not null
#

# TODO: delete this class (and `PGDECourse`) after the UCAS transition is finished

FactoryBot.define do
  factory :pgde_course do
  end
end
