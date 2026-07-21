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
      subquery = Course
                 .joins(site_statuses: :site)
                 .joins(school_identity_joins)
                 .where(id: @courses.map(&:id))
                 .where("site.longitude IS NOT NULL AND site.latitude IS NOT NULL")
                 .select(select_sql)
                 .order("course.id, distance_to_search_location ASC")

      Course
        .from(subquery, :course)
        .order("distance_to_search_location ASC")
    end

  private

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
