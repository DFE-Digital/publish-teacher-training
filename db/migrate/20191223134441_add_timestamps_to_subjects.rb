class AddTimestampsToSubjects < ActiveRecord::Migration[6.0]
  def change
    change_table :subject, bulk: true do |t|
      t.timestamps(null: true)
    end
  end
end
