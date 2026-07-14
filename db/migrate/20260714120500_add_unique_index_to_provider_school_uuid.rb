# frozen_string_literal: true

class AddUniqueIndexToProviderSchoolUuid < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :provider_school, :uuid, unique: true, algorithm: :concurrently
  end
end
