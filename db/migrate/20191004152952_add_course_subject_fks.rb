class AddCourseSubjectFks < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :course_subject, :course
    add_foreign_key :course_subject, :subject
  end
end
