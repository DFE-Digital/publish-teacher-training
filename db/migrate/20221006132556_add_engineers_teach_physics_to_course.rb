class AddEngineersTeachPhysicsToCourse < ActiveRecord::Migration[7.0]
  def change
    add_column :course, :engineers_teach_physics_query, :boolean, default: false
    add_index :course, :engineers_teach_physics_query
  end
end
