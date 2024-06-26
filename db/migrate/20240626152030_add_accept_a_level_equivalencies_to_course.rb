class AddAcceptALevelEquivalenciesToCourse < ActiveRecord::Migration[7.1]
  def change
    add_column :course, :accept_a_level_equivalencies, :boolean
  end
end
