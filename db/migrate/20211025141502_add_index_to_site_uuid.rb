class AddIndexToSiteUuid < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :site, :uuid, unique: true, name: "index_sites_unique_uuid", algorithm: :concurrently
  end
end
