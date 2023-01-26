# frozen_string_literal: true

class RemoveNullConstraintFromUserState < ActiveRecord::Migration[6.0]
  def change
    change_column_null :user, :state, true
  end
end
