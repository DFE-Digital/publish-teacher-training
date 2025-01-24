# frozen_string_literal: true

class RemoveAccreditedProviderNumber < ActiveRecord::Migration[8.0]
  def up
    Provider.where.not(accredited: true).update_all(accredited_provider_number: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
