class CreateAPIKey < ActiveRecord::Migration[8.1]
  def change
    create_table :api_key, if_not_exists: true do |t|
      t.text :email, null: false, index: true
      t.string :name, null: false
      t.string :key_digest, null: false
      t.string :prefix, null: false
      t.datetime :last_used_at
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :api_key, :key_digest, unique: true, if_not_exists: true
  end
end
