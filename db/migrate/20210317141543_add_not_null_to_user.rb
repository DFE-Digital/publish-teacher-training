# frozen_string_literal: true

class AddNotNullToUser < ActiveRecord::Migration[6.1]
  def change
    # rubocop:disable Rails/BulkChangeTable
    change_column_null(:user, :first_name, false)
    change_column_null(:user, :last_name, false)
    # rubocop:enable Rails/BulkChangeTable
  end
end
