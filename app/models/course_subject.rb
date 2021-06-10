class CourseSubject < ApplicationRecord
  self.table_name = "course_subject"

  belongs_to :course
  belongs_to :subject
  validates :subject_id, uniqueness: { scope: :course_id }

  audited associated_with: :course
end
