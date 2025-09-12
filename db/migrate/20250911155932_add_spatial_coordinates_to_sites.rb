class AddSpatialCoordinatesToSites < ActiveRecord::Migration[8.0]
  def change
    add_column :site,
               :coordinates,
               :virtual,
               type: :st_point,
               as: "CASE
                    WHEN longitude IS NOT NULL AND latitude IS NOT NULL
                    THEN ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
                    ELSE NULL
                  END",
               geographic: true,
               stored: true

    add_index :site, :coordinates, using: :gist, where: "coordinates IS NOT NULL"
  end
end
