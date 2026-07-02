# frozen_string_literal: true

# activerecord-postgis-adapter reports `connection.adapter_name` as "PostGIS",
# which causes geokit-rails to look for a non-existent
# `geokit-rails/adapters/postgis` file and raise UnsupportedAdapter. Alias it
# to the PostgreSQL adapter so distance_sql / within / etc. work.
require "geokit-rails/adapters/postgresql"
Geokit::Adapters::PostGIS = Geokit::Adapters::PostgreSQL
