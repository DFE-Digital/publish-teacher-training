class AddLevelToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :course, :level, :string
  end
end
