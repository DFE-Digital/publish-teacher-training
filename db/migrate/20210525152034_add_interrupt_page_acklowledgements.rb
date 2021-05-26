class AddInterruptPageAcklowledgements < ActiveRecord::Migration[6.1]
  def change
    create_table :interrupt_page_acknowledgement do |t|
      t.string :page, null: false
      t.references :recruitment_cycle, null: false
      t.references :user, null: false

      t.timestamps

      t.index [:page, :recruitment_cycle_id, :user_id], unique: true, name: :interrupt_page_all_column_idx
    end
  end
end
