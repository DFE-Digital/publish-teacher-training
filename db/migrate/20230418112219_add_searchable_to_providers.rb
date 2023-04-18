# frozen_string_literal: true

class AddSearchableToProviders < ActiveRecord::Migration[7.0]
  def up
    add_column :provider, :searchable, :tsvector
    add_index :provider, :searchable, using: :gin
    add_index :provider, :accrediting_provider, where: "accrediting_provider = 'Y'"
  end

  def down
    remove_column :provider, :searchable
  end
end
