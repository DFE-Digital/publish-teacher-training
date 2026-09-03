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

    # The two DISTINCT ON keys the callers choose between. Constants rather than
    # caller-built strings so nothing reaches the SELECT that is not written here.
    NEAREST_PER_COURSE = "course.id"
    EACH_SCHOOL_PER_COURSE = "course.id, gias_school.id"

  private

    # The whole SELECT goes through sanitize_sql_array: the only values that come
    # from outside are the search coordinates, bound as parameters rather than
    # interpolated (and coerced with Float first, so a non-numeric raises here
    # rather than reaching the database).
    #
    # ST_Distance takes the trailing `false` to force sphere maths, matching the
    # legacy ST_DistanceSphere path and Courses::Query#schools_location_scope;
    # metres are converted with the same Geolocation::METRES_PER_MILE the results
    # page uses, so a course's distance reads the same on the card and its own page.
    #
    # The CASE reproduces Provider::School#location_name in SQL.
    def school_columns_sql(distinct_on)
      Course.sanitize_sql_array(
        [
          <<~SQL.squish,
            DISTINCT ON (#{distinct_on}) course.id AS course_id,
            course.*,
            provider_school.uuid AS provider_school_uuid,
            CASE
              WHEN provider_school.site_code = ?
              THEN gias_school.name || ' (Main Site)'
              ELSE gias_school.name
            END AS location_name,
            gias_school.latitude,
            gias_school.longitude,
            ST_Distance(
              gias_school.geo_location,
              ST_SetSRID(ST_MakePoint(?::float, ?::float), 4326)::geography,
              false
            ) / ? AS distance_to_search_location
          SQL
          Provider::School::MAIN_SITE_CODE,
          Float(@longitude),
          Float(@latitude),
          Geolocation::METRES_PER_MILE,
        ],
      )
    end
  end
end
