class AddLatitudeAndLongitudeToProvider < ActiveRecord::Migration[6.0]
  def change
    change_table :provider, bulk: true do |t|
      t.float :latitude
      t.float :longitude
      t.index %i[latitude longitude]
    end
  end
end
