# frozen_string_literal: true

class AddAddress3ToSite < ActiveRecord::Migration[7.0]
  def change
    add_column :site, :address3, :text
  end
end
