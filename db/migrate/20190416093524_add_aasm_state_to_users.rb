class AddAasmStateToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :user, :state, :string
  end
end
