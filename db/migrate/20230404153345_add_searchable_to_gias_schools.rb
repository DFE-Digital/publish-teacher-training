# frozen_string_literal: true

class AddSearchableToGiasSchools < ActiveRecord::Migration[7.0]
  def up
    add_column :gias_school, :searchable, :tsvector
    add_index :gias_school, :searchable, using: :gin
    add_index :gias_school, :status_code, where: "status_code = '1'"
  end

  def down
    remove_column :gias_school, :searchable
  end
end
