# frozen_string_literal: true

class AddAdditionalALevelEquivalenciesToCourse < ActiveRecord::Migration[7.1]
  def change
    add_column :course, :additional_a_level_equivalencies, :text
  end
end
