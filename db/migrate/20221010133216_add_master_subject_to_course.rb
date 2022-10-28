class AddMasterSubjectToCourse < ActiveRecord::Migration[7.0]
  def change
    add_column :course, :master_subject_id, :integer
    add_index :course, :master_subject_id
  end
end
