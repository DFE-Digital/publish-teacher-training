# == Schema Information
#
# Table name: pgde_course
#
#  id            :integer          not null, primary key
#  course_code   :text             not null
#  provider_code :text             not null
#

class PGDECourse < ApplicationRecord
  def self.is_one?(course)
    where(
      course_code: course.course_code,
      provider_code: course.provider.provider_code
    ).exists?
  end
end
