class AddLatitudeAndLongitudeToProvider < ActiveRecord::Migration[6.0]
  def change
    add_column :provider, :latitude, :float
    add_column :provider, :longitude, :float
    add_index :provider, %i[latitude longitude]
  end
end
