class AddStateToCourse < ActiveRecord::Migration[6.0]
  def change
    add_column :course, :state, :string
  end
end
