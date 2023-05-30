# frozen_string_literal: true

class AddTypeToSite < ActiveRecord::Migration[7.0]
  def change
    add_column :site, :site_type, :integer, default: 0, null: false
    add_index :site, :site_type
  end
end
