# frozen_string_literal: true

class RemoveOptedInFromProvider < ActiveRecord::Migration[5.2]
  def change
    remove_column :provider, :opted_in, :boolean, default: false
  end
end
