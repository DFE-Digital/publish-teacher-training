# frozen_string_literal: true

class ChangeColumnAccreditingProviderToBoolean < ActiveRecord::Migration[8.0]
  def change
    add_column :provider, :accredited, :boolean, null: false, default: false

    add_index :provider, :accredited
  end
end
