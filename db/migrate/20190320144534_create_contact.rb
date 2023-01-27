# frozen_string_literal: true

class CreateContact < ActiveRecord::Migration[5.2]
  def change
    create_table :contact do |t|
      t.integer :provider_id, null: false
      t.text :type, null: false
      t.text :name
      t.text :email
      t.text :telephone

      t.index :provider_id

      t.timestamps
    end
  end
end
