class AddGeoLocationToGiasSchool < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  # Canonical spatial column on the one-row-per-school table, plus a partial GiST
  # index so location search can prune far-away schools with ST_DWithin instead of
  # computing ST_DistanceSphere for every candidate.
  #
  # geo_location stores geography(Point, 4326) (true lat/long, metres on a sphere)
  # derived from the existing float columns. The ::geography cast of
  # ST_SetSRID(ST_MakePoint(...)) is IMMUTABLE, so it is legal in a STORED
  # generated column (ST_Transform is not, and would be rejected). Note the
  # argument order: ST_MakePoint(X, Y) = (longitude, latitude).
  def up
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE gias_school
          ADD COLUMN geo_location geography(Point, 4326)
          GENERATED ALWAYS AS ((ST_SetSRID(ST_MakePoint(longitude, latitude), 4326))::geography) STORED
      SQL
    end

    # Only in-coordinate schools are indexed; NULL coordinates (awaiting geocoding)
    # are excluded so the index stays lean and never matches a search.
    add_index :gias_school, :geo_location,
              using: :gist,
              where: "geo_location IS NOT NULL",
              name: "index_gias_school_on_geo_location",
              algorithm: :concurrently

    # Make the school -> course fan-out (phase 2 of the search) index-only.
    add_index :course_school, :gias_school_id,
              include: %i[course_id],
              name: "index_course_school_fanout",
              algorithm: :concurrently
  end

  def down
    remove_index :course_school, name: "index_course_school_fanout", algorithm: :concurrently
    remove_index :gias_school, name: "index_gias_school_on_geo_location", algorithm: :concurrently
    safety_assured { execute "ALTER TABLE gias_school DROP COLUMN geo_location" }
  end
end
