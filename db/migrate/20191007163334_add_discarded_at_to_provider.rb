class AddDiscardedAtToProvider < ActiveRecord::Migration[6.0]
  def change
    add_column :provider, :discarded_at, :datetime
    add_index :provider, :discarded_at
  end
end
