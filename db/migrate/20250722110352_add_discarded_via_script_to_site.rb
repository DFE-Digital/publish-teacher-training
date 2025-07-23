class AddDiscardedViaScriptToSite < ActiveRecord::Migration[8.0]
  def change
    add_column :site, :discarded_via_script, :boolean
    add_index :site, :discarded_via_script
  end
end
