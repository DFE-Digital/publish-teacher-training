# frozen_string_literal: true

class ChangeAddress3ToTown < ActiveRecord::Migration[7.0]
  def change
    rename_column :site, :address3, :town
  end
end
