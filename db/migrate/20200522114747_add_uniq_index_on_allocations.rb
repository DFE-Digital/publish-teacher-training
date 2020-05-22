class AddUniqIndexOnAllocations < ActiveRecord::Migration[6.0]
  def change
    add_index :allocation, %i[provider_id accredited_body_id provider_code accredited_body_code recruitment_cycle_id], unique: true, name: "index_allocations_on_uniqueness_of_codes_and_ids"
  end
end
