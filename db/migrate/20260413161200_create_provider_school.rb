# frozen_string_literal: true

class CreateProviderSchool < ActiveRecord::Migration[8.1]
  def change
    create_table :provider_school do |t|
      t.bigint :provider_id, null: false
      t.bigint :gias_school_id, null: false
      t.text :site_code, null: false
      t.timestamps
    end

    add_foreign_key :provider_school, :provider, on_delete: :cascade
    add_foreign_key :provider_school, :gias_school, on_delete: :cascade

    add_index :provider_school, :gias_school_id
    add_index :provider_school, %i[provider_id gias_school_id site_code],
              unique: true,
              name: "index_provider_school_unique"
    add_index :provider_school, :provider_id,
              unique: true,
              where: "site_code = '-'",
              name: "index_provider_school_one_main_per_provider"
  end
end
