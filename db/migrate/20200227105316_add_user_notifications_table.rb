class AddUserNotificationsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :user_notification do |t|
      t.integer :user_id, null: false
      t.string :provider_code, null: false
      t.boolean :course_update, default: false

      t.timestamps
    end

    add_foreign_key :user_notification, :user
    add_index :user_notification, :provider_code
  end
end
