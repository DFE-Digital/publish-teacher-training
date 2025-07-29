class AddAddedViaToSites < ActiveRecord::Migration[8.0]
  def change
    add_column :site, :added_via, :string, null: false, default: "publish_interface"
    add_index  :site, :added_via
  end
end
