class AddSubjectAreaIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :subject_area, :typename
  end
end
