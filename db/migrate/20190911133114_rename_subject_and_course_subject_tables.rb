class RenameSubjectAndCourseSubjectTables < ActiveRecord::Migration[5.2]
  def change
    rename_table :subject, :ucas_subject
    rename_table :course_subject, :course_ucas_subject
  end
end
