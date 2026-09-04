# frozen_string_literal: true

require_dependency Rails.root.join("app/lib/multiple_parameters_date_type")
require_dependency Rails.root.join("app/lib/multiple_parameters_date_time_type")

ActiveRecord::SchemaDumper.ignore_tables |= %w[
  airbyte_heartbeat
  geography_columns
  geometry_columns
  layer
  raster_columns
  raster_overviews
  spatial_ref_sys
  topology
]

ActiveModel::Type.register(:multiple_parameters_date, MultipleParametersDateType)
ActiveModel::Type.register(:multiple_parameters_date_time, MultipleParametersDateTimeType)
