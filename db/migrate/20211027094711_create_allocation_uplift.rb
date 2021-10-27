class CreateAllocationUplift < ActiveRecord::Migration[6.1]
  def change
    create_table :allocation_uplift do |t|
      t.belongs_to :allocation, foreign_key: true
      t.integer :uplifts

      t.timestamps
    end
  end
end
