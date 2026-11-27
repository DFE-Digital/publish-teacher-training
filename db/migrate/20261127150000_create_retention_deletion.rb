# frozen_string_literal: true

class CreateRetentionDeletion < ActiveRecord::Migration[8.1]
  def change
    create_table :retention_deletion do |t|
      t.text :entity_type, null: false
      t.text :entity_id, null: false
      t.jsonb :deleted_records, null: false
      t.datetime :deleted_at, null: false
      t.datetime :created_at, null: false
    end
  end
end
