class RemoveDiscardIndexesFromSite < ActiveRecord::Migration[6.1]
  def change
    change_table :site do |t|
      t.remove_index(name: "idx_site_code_discarded_at_not_null")
      t.remove_index(name: "idx_site_code_discarded_at_null")
    end
  end
end
