# frozen_string_literal: true

class RemoveAddedViaFromSite < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    remove_index :site, name: "index_site_on_added_via", algorithm: :concurrently, if_exists: true
    safety_assured { remove_column :site, :added_via }
  end

  def down
    add_column :site, :added_via, :string, null: false, default: "publish_interface", if_not_exists: true
    add_index :site, :added_via, name: "index_site_on_added_via", algorithm: :concurrently, if_not_exists: true
  end
end
