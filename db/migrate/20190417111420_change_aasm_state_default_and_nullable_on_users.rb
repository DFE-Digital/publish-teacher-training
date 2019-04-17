class ChangeAasmStateDefaultAndNullableOnUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_null :user, :aasm_state, false, User.aasm.initial_state
  end
end
