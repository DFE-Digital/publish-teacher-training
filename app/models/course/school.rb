# frozen_string_literal: true

class Course::School < ApplicationRecord
  self.table_name = "course_school"

  belongs_to :course, class_name: "::Course", inverse_of: :schools
  belongs_to :gias_school

  validates :site_code, presence: true
  validates :gias_school_id, uniqueness: { scope: %i[course_id site_code] }
end
