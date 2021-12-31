class AddDiscardedAtToSite < ActiveRecord::Migration[6.1]
  def change
    add_column :site, :discarded_at, :datetime
    add_index :site, :discarded_at
  end
end
