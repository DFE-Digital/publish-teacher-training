class AddMissingSubjectAreaFk < ActiveRecord::Migration[6.0]
  def change
    remove_index :subject_area, :typename
    add_index :subject_area, :typename, unique: true
    add_foreign_key :subject, :subject_area, column: :type, primary_key: :typename, name: "fk_subject__subject_area"
  end
end
