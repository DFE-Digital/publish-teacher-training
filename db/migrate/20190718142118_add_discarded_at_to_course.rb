class AddDiscardedAtToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :course, :discarded_at, :datetime
    add_index :course, :discarded_at
  end
end
