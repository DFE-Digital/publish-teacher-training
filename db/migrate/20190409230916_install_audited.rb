class InstallAudited < ActiveRecord::Migration[5.2]
  def self.up
    create_table :audit, force: true do |t|
      t.integer  :auditable_id
      t.string   :auditable_type
      t.integer  :associated_id
      t.string   :associated_type
      t.integer  :user_id
      t.string   :user_type
      t.string   :username
      t.string   :action
      t.jsonb    :audited_changes
      t.integer  :version, default: 0
      t.string   :comment
      t.string   :remote_address
      t.string   :request_uuid
      t.datetime :created_at
    end

    add_index :audit, %i[auditable_type auditable_id version], name: "auditable_index"
    add_index :audit, %i[associated_type associated_id], name: "associated_index"
    add_index :audit, %i[user_id user_type], name: "user_index"
    add_index :audit, :request_uuid
    add_index :audit, :created_at
  end

  def self.down
    drop_table :audit
  end
end
