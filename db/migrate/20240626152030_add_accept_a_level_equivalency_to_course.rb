# frozen_string_literal: true

class AddAcceptALevelEquivalencyToCourse < ActiveRecord::Migration[7.1]
  def change
    add_column :course, :accept_a_level_equivalency, :boolean
  end
end
