class AddRegionCodeToGiasSchool < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :gias_school, :region_code, :string
    add_index :gias_school, :region_code, algorithm: :concurrently
  end
end
