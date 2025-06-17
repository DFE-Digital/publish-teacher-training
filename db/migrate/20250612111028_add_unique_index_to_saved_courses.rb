class AddUniqueIndexToSavedCourses < ActiveRecord::Migration[8.0]
  def change
    add_index :saved_course, %i[candidate_id course_id], unique: true
  end
end
