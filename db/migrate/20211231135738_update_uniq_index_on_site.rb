class UpdateUniqIndexOnSite < ActiveRecord::Migration[6.1]
  def change
    change_table :site do |t|
      t.remove_index(name: "IX_site_provider_id_code")
      t.index %i[provider_id code], where: "(discarded_at IS NOT NULL)", name: "idx_site_code_discarded_at_not_null"
      t.index %i[provider_id code], where: "(discarded_at IS NULL)", name: "idx_site_code_discarded_at_null"
    end
  end
end
