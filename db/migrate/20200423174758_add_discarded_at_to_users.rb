class AddDiscardedAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :user, :discarded_at, :datetime
    add_index :user, :discarded_at
  end
end
