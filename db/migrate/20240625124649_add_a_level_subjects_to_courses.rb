class AddALevelSubjectsToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :course, :a_level_subject_requirements, :jsonb, default: []
  end
end
