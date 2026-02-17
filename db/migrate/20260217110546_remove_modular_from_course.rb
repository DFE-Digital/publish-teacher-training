class RemoveModularFromCourse < ActiveRecord::Migration[8.0]
  def change
    remove_column :course, :modular, :text
  end
end
