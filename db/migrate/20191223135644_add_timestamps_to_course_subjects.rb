class AddTimestampsToCourseSubjects < ActiveRecord::Migration[6.0]
  def change
    change_table :course_subject, bulk: true do |t|
      t.timestamps(null: true)
    end
  end
end
