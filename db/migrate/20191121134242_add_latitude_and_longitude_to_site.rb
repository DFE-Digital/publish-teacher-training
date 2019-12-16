class AddLatitudeAndLongitudeToSite < ActiveRecord::Migration[6.0]
  def change
    change_table :site, bulk: true do |t|
      t.float :latitude
      t.float :longitude
      t.index %i[latitude longitude]
    end
  end
end
