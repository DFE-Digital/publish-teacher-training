class RemoveUserForeignKeyFromAPIKey < ActiveRecord::Migration[8.1]
  def up
    remove_foreign_key :api_key, :user, column: :email, if_exists: true
  end

  def down; end
end
