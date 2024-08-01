# frozen_string_literal: true

class AddFundingTypeToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :course, :funding, :string, default: 'fee', null: false
  end
end
