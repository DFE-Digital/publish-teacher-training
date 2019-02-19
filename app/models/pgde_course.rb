# == Schema Information
#
# Table name: pgde_course
#
#  id            :integer          not null, primary key
#  course_code   :text             not null
#  provider_code :text             not null
#

class PgdeCourse < ApplicationRecord
end
