class CreateUserPermission < ActiveRecord::Migration[6.1]
  def change
    create_table :user_permission do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :provider, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
