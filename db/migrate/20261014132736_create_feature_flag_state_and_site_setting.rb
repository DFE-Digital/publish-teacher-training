# frozen_string_literal: true

class CreateFeatureFlagStateAndSiteSetting < ActiveRecord::Migration[8.1]
  # Database restores replace schema_migrations with production's copy but keep
  # tables that are not in the production dump, so this can run on a database
  # that already has these tables.
  def change
    create_table :feature_flag_state, if_not_exists: true do |t|
      t.string :name, null: false
      t.boolean :active, null: false, default: false
      t.timestamps
      t.index :name, unique: true
    end

    create_table :site_setting, if_not_exists: true do |t|
      t.string :name, null: false
      t.string :value, null: false
      t.timestamps
      t.index :name, unique: true
    end
  end
end
