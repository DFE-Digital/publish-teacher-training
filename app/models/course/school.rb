# frozen_string_literal: true

class Course::School < ApplicationRecord
  include TouchCourse

  self.table_name = "course_school"

  belongs_to :course, class_name: "::Course", inverse_of: :schools
  belongs_to :gias_school
  belongs_to :provider_school, class_name: "Provider::School", inverse_of: :course_schools

  validates :site_code, presence: true
  validates :gias_school_id, uniqueness: { scope: %i[course_id site_code] }
end
