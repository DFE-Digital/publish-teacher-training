class RemoveUnusedSubjectColumns < ActiveRecord::Migration[6.0]
  def up
    change_table :subject, bulk: true do |t|
      t.remove :created_at
      t.remove :updated_at
      t.remove :subject_area_id
    end
  end

  def down
    change_table :subject, bulk: true do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :subject_area_id
    end
  end
end
