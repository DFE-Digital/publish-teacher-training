# frozen_string_literal: true

class AddBlazerAccessToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :user, :blazer_access, :boolean, default: false, null: false
  end
end
