class AddDiscardedAtToAccessRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :access_request, :discarded_at, :datetime
    add_index :access_request, :discarded_at
  end
end
