# frozen_string_literal: true

module Courses
  # Shared SQL for the two canonical course_school -> gias_school distance queries.
  #
  # NearestSchoolQuery and SchoolDistancesQuery differ only in how many rows they
  # keep per course, so the distance maths and the school columns live here. If the
  # two drifted apart, the course page and the ?debug panel would quietly disagree
  # about how far away the same school is.
  module CanonicalSchoolDistance
    # geo_location is a stored generated column, so it is NULL whenever either
    # coordinate is missing - one guard covers both, and the partial GiST index
    # index_gias_school_on_geo_location covers the guard.
    GEOCODED_SCHOOL = "gias_school.geo_location IS NOT NULL"

  private

    # ST_Distance takes the trailing `false` to force sphere maths, matching the
    # legacy ST_DistanceSphere path and Courses::Query#schools_location_scope;
    # metres are converted with the same 1609.344 the results page uses, so a
    # course's distance reads the same on the results card and on its own page.
    #
    # The CASE reproduces Provider::School#location_name in SQL.
    def school_columns_sql
      <<~SQL.squish
        course.id AS course_id,
        course.*,
        provider_school.uuid AS provider_school_uuid,
        CASE
          WHEN provider_school.site_code = #{Course.connection.quote(Provider::School::MAIN_SITE_CODE)}
          THEN gias_school.name || ' (Main Site)'
          ELSE gias_school.name
        END AS location_name,
        gias_school.latitude,
        gias_school.longitude,
        ST_Distance(gias_school.geo_location, #{search_point}, false) / 1609.344 AS distance_to_search_location
      SQL
    end

    def search_point
      Course.sanitize_sql_array(
        ["ST_SetSRID(ST_MakePoint(?::float, ?::float), 4326)::geography", Float(@longitude), Float(@latitude)],
      )
    end
  end
end
