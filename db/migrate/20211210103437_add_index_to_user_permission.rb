class AddIndexToUserPermission < ActiveRecord::Migration[6.1]
  def change
    add_index(:user_permission, [:user_id, :provider_id], unique: true)
  end
end
