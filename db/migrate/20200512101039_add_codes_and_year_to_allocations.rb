class AddCodesAndYearToAllocations < ActiveRecord::Migration[6.0]
  def change
    change_table :allocation, bulk: true do |t|
      t.text :accredited_body_code
      t.text :provider_code
      t.integer :recruitment_cycle_id
    end
  end
end
