# frozen_string_literal: true

class AddDegreeTypeToCourse < ActiveRecord::Migration[7.2]
  def change
    add_column :course, :degree_type, :string, default: 'postgraduate', null: false
  end
end
