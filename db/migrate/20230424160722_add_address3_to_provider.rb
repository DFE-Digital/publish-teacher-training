# frozen_string_literal: true

class AddAddress3ToProvider < ActiveRecord::Migration[7.0]
  def change
    add_column :provider, :address3, :text
  end
end
