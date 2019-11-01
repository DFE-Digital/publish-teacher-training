# == Schema Information
#
# Table name: course_subject
#
#  course_id  :integer
#  id         :integer          not null, primary key
#  subject_id :integer
#
# Indexes
#
#  index_course_subject_on_course_id                 (course_id)
#  index_course_subject_on_course_id_and_subject_id  (course_id,subject_id) UNIQUE
#  index_course_subject_on_subject_id                (subject_id)
#

class CourseSubject < ApplicationRecord
  self.table_name = "course_subject"

  belongs_to :course
  belongs_to :subject

  audited associated_with: :course
end
