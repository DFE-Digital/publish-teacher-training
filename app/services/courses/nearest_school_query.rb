# frozen_string_literal: true

module Courses
  # Finds only nearest school per course
  #
  class NearestSchoolQuery
    def initialize(courses:, latitude:, longitude:)
      @courses = courses
      @latitude = latitude
      @longitude = longitude
    end

    def call
      subquery =
        if FeatureFlag.active?(:course_publishing_uses_new_school_model)
          schools_subquery
        else
          sites_subquery
        end

      Course
        .from(subquery, :course)
        .order("distance_to_search_location ASC")
    end

  private

    # Nearest school over the canonical course_school -> gias_school model, used
    # while the :course_publishing_uses_new_school_model flag is on.
    #
    # DISTINCT ON (course.id) does double duty: it reduces a course's schools to
    # the nearest one, and it absorbs the duplicates a course picks up when two of
    # its Provider::Schools share a GiasSchool - legal, because course_school is
    # unique on (course_id, provider_school_id), not on gias_school_id.
    # The gias_school.id tiebreaker keeps that pick stable between runs.
    def schools_subquery
      Course
        .joins(schools: %i[gias_school provider_school])
        .where(id: @courses.map(&:id))
        .where("gias_school.geo_location IS NOT NULL")
        .select(schools_select_sql)
        .order("course.id, distance_to_search_location ASC, gias_school.id ASC")
    end

    def sites_subquery
      Course
        .joins(site_statuses: :site)
        .joins(school_identity_joins)
        .where(id: @courses.map(&:id))
        .where("site.longitude IS NOT NULL AND site.latitude IS NOT NULL")
        .select(select_sql)
        .order("course.id, distance_to_search_location ASC")
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
        DISTINCT ON (course.id) course.id AS course_id,
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
        DISTINCT ON (course.id) course.id as course_id,
        course.*,
        site.id AS site_id,
        site.uuid AS site_uuid,
        provider_school.uuid AS provider_school_uuid,
        site.location_name,
        site.latitude,
        site.longitude,
        ST_DistanceSphere(
          ST_SetSRID(ST_MakePoint(site.longitude::float, site.latitude::float), 4326),
          ST_SetSRID(ST_MakePoint(#{Float(@longitude)}, #{Float(@latitude)}), 4326)
        ) / 1609.34 AS distance_to_search_location
      SQL
    end

    def school_identity_joins
      <<~SQL.squish
        LEFT JOIN gias_school ON gias_school.urn = site.urn
        LEFT JOIN provider_school ON provider_school.provider_id = site.provider_id
          AND provider_school.gias_school_id = gias_school.id
          AND provider_school.site_code = site.code
      SQL
    end
  end
end
