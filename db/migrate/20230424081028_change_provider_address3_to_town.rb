class ChangeProviderAddress3ToTown < ActiveRecord::Migration[7.0]
  def change
    rename_column :provider, :address3, :town
  end
end
