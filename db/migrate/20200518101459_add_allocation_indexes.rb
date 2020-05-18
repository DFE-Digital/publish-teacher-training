class AddAllocationIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :allocation, %i[recruitment_cycle_id accredited_body_code provider_code], name: "index_allocation_recruitment_and_codes"
  end
end
