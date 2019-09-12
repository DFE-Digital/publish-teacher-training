class CourseSubject < ApplicationRecord
  self.table_name = 'course_subject'

  belongs_to :course
  belongs_to :subject
end
