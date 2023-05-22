# frozen_string_literal: true

class AddApplicationStatusToCourse < ActiveRecord::Migration[7.0]
  def change
    add_column :course, :application_status, :integer, default: 0, null: false
    add_index :course, :application_status
  end
end
