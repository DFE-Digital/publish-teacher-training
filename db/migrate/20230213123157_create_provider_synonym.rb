# frozen_string_literal: true

class CreateProviderSynonym < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_synonym do |t|
      t.text :provider_code, null: false
      t.text :synonym
      t.text :match_synonym
      t.timestamps
    end
  end
end
