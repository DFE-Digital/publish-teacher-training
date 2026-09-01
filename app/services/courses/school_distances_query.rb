# frozen_string_literal: true

module Courses
  # This query class fetches distances between given courses' schools and a specified location.
  #
  # This is more an utility class that can help understand the school locations
  #
  # It can be used to retrieve:
  #   - All schools for a set of courses, with their distances.
  #
  # Usage:
  #   - To find the school distances for a list of courses:
  #       Courses::SchoolsDistancesQuery.new(courses: some_courses, latitude: 51.5, longitude: -0.1).call
  #
  #   - To analyze all schools associated with a provider (including accredited courses):
  #
  #       provider_courses = (provider.courses + provider.accredited_courses).uniq
  #       Courses::SchoolsDistancesQuery.new(courses: provider_courses, latitude: 51.5, longitude: -0.1).call
  #
  # Then you can access the distance through #distance_to_search_location
  #
  class SchoolDistancesQuery
    def initialize(courses:, latitude:, longitude:)
      @courses = courses
      @latitude = latitude
      @longitude = longitude
    end

    def call
      if FeatureFlag.active?(:course_publishing_uses_new_school_model)
        schools_query
      else
        sites_query
      end
    end

  private

    # Every school of every course over the canonical course_school -> gias_school
    # model, used while the :course_publishing_uses_new_school_model flag is on.
    #
    # DISTINCT ON (course.id, gias_school.id) is the counterpart of the legacy
    # GROUP BY (course.id, site.id): it lists a school once per course however many
    # of the course's Provider::Schools point at it, without having to aggregate the
    # provider_school columns the SELECT needs. The subquery is re-wrapped so the
    # rows can be ordered by distance rather than by the DISTINCT ON key.
    def schools_query
      subquery = Course
                 .joins(schools: %i[gias_school provider_school])
                 .where(id: @courses.map(&:id))
                 .where("gias_school.geo_location IS NOT NULL")
                 .select(schools_select_sql)
                 .order("course.id, gias_school.id, provider_school.site_code ASC")

      Course
        .from(subquery, :course)
        .order("course_id ASC, distance_to_search_location ASC")
    end

    def sites_query
      Course
        .joins(site_statuses: :site)
        .where(id: @courses.map(&:id))
        .where("site.longitude IS NOT NULL AND site.latitude IS NOT NULL")
        .select(select_sql)
        .order("course.id, distance_to_search_location ASC")
        .group("course.id, site.id")
    end

    # geo_location is a stored generated column, so it is NULL whenever either
    # coordinate is missing - one guard covers both. ST_Distance takes the
    # trailing `false` to force sphere maths, matching the legacy
    # ST_DistanceSphere path and Courses::Query#schools_location_scope, and
    # metres are converted with the same 1609.344 the results page uses.
    #
    # The CASE reproduces Provider::School#location_name in SQL.
    def schools_select_sql
      <<~SQL.squish
        DISTINCT ON (course.id, gias_school.id) course.id AS course_id,
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

    def select_sql
      <<~SQL.squish
        course.id AS course_id,
        course.*,
        site.id AS site_id,
        site.location_name,
        site.latitude,
        site.longitude,
        ST_DistanceSphere(
          ST_SetSRID(ST_MakePoint(site.longitude::float, site.latitude::float), 4326),
          ST_SetSRID(ST_MakePoint(#{Float(@longitude)}, #{Float(@latitude)}), 4326)
        ) / 1609.34 AS distance_to_search_location
      SQL
    end
  end
end
