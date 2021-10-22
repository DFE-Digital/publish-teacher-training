class AddUuidToSite < ActiveRecord::Migration[6.1]
  def change
    add_column :site, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    add_index :site, :uuid, unique: true, name: "index_sites_unique_uuid"
  end
end
