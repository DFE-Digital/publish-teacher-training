# frozen_string_literal: true

module Courses
  # Finds only nearest school per course
  #
  class NearestSchoolQuery
    include CanonicalSchoolDistance

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
    #
    # Those duplicates tie on distance and on gias_school.id, so site_code breaks
    # the tie: without it Postgres could return either provider school, and the
    # ?debug panel's link and "(Main Site)" label would flip between page loads.
    def schools_subquery
      Course
        .joins(schools: %i[gias_school provider_school])
        .where(id: @courses.map(&:id))
        .where(GEOCODED_SCHOOL)
        .select(school_columns_sql(NEAREST_PER_COURSE))
        .order("course.id, distance_to_search_location ASC, gias_school.id ASC, provider_school.site_code ASC")
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
        ) / #{Geolocation::METRES_PER_MILE} AS distance_to_search_location
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
