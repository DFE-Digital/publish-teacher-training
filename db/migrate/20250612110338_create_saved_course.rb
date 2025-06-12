class CreateSavedCourse < ActiveRecord::Migration[8.0]
  def change
    create_table :saved_course do |t|
      t.references :candidate, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
