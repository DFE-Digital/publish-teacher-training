# frozen_string_literal: true

class AddProviderPartnership < ActiveRecord::Migration[7.2]
  def change
    create_table :provider_partnership do |t|
      t.bigint :accredited_provider_id, null: false, index: true
      t.bigint :training_provider_id, null: false, index: true
      t.text :description

      t.timestamps
    end

    add_index :provider_partnership, %i[accredited_provider_id training_provider_id], unique: true
  end
end
