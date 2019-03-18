class ChangeChangedAtToUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :provider, :changed_at, unique: true
    add_index :course, :changed_at, unique: true
  end
end
