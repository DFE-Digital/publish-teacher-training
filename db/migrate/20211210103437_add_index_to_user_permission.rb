class AddIndexToUserPermission < ActiveRecord::Migration[6.1]
  def change
    add_index(:user_permission, %i[user_id provider_id], unique: true)
  end
end
