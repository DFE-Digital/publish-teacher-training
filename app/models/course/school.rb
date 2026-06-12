# frozen_string_literal: true

class Course::School < ApplicationRecord
  include TouchCourse

  self.table_name = "course_school"

  belongs_to :course, class_name: "::Course", inverse_of: :schools
  belongs_to :gias_school

  validates :site_code, presence: true
  validates :gias_school_id, uniqueness: { scope: %i[course_id site_code] }
  validates :gias_school_id,
            uniqueness: {
              scope: :course_id,
              conditions: -> { where.not(site_code: Provider::School::MAIN_SITE_CODE) },
            },
            if: -> { site_code != Provider::School::MAIN_SITE_CODE }
end
