# frozen_string_literal: true

class RenameColumnToAccrediteProviderNumber < ActiveRecord::Migration[7.2]
  def change
    rename_column :provider, :accredited_provider_id, :accredited_provider_number
  end
end
