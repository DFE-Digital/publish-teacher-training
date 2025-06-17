class AddPolymorphicSessionsTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :session, force: :cascade, if_exists: true

    create_table :session do |t|
      t.string :user_agent
      t.string :ip_address
      t.string :id_token
      t.string :session_key, null: false
      t.jsonb :data, default: {}
      t.references :sessionable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :session, :updated_at, if_not_exists: true
    add_index :session, :session_key, unique: true, if_not_exists: true
  end

  def down
    drop_table :session, if_exists: true
  end
end
