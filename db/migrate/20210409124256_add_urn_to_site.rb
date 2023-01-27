# frozen_string_literal: true

class AddUrnToSite < ActiveRecord::Migration[6.1]
  def change
    add_column :site, :urn, :string
  end
end
