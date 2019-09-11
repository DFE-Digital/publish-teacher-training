# == Schema Information
#
# Table name: course_subject
#
#  id         :integer          not null, primary key
#  course_id  :integer
#  subject_id :integer
#

class CourseUCASSubject < ApplicationRecord
  self.table_name = 'course_subject'

  belongs_to :course
  belongs_to :subject
end
