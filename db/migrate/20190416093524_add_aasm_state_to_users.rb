class AddAasmStateToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :user, :aasm_state, :string
  end
end
