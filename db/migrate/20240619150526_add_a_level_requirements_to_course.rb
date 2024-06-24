# frozen_string_literal: true

class AddALevelRequirementsToCourse < ActiveRecord::Migration[7.1]
  def change
    add_column :course, :a_level_requirements, :boolean
  end
end
