class CreateSubjectGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :subject_group do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_reference :subject, :subject_group, foreign_key: true, index: true
  end
end
