# frozen_string_literal: true

class AddFundingTypeToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :course, :funding, :string, default: 'not_set', null: false
    add_index :course, :funding
  end
end
