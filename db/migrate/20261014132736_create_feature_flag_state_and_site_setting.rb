# frozen_string_literal: true

class CreateFeatureFlagStateAndSiteSetting < ActiveRecord::Migration[8.1]
  def change
    create_table :feature_flag_state do |t|
      t.string :name, null: false
      t.boolean :active, null: false, default: false
      t.timestamps
      t.index :name, unique: true
    end

    create_table :site_setting do |t|
      t.string :name, null: false
      t.string :value, null: false
      t.timestamps
      t.index :name, unique: true
    end
  end
end
