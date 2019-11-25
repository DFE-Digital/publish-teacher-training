class AddLatitudeAndLongitudeToSite < ActiveRecord::Migration[6.0]
  def change
    add_column :site, :latitude, :float
    add_column :site, :longitude, :float
    add_index :site, %i[latitude longitude]
  end
end
