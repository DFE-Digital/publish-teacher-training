class ChangeIndexOnCourseSchool < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index :course_school, %w[course_id gias_school_id site_code], name: :index_course_school_unique, unique: true, algorithm: :concurrently
    add_index :course_school, %i[course_id provider_school_id], unique: true, algorithm: :concurrently
  end
end
