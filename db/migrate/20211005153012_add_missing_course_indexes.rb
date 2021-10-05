class AddMissingCourseIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :course, :program_type
    add_index :course, :qualification
    add_index :course, :study_mode
    add_index :course, :is_send
    add_index :course, :degree_grade
  end
end
