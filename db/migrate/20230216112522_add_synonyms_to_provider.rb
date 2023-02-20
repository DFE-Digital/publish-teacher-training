# frozen_string_literal: true

class AddSynonymsToProvider < ActiveRecord::Migration[7.0]
  def change
    add_column :provider, :synonyms, :string, array: true, default: []
    add_index :provider, :synonyms, using: 'gin'
  end
end
