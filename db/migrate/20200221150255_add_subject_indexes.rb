class AddSubjectIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :subject, :type
    add_index :subject, :subject_code
  end
end
