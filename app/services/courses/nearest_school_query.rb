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
                 .where(id: @courses.map(&:id))
                 .where('site.longitude IS NOT NULL AND site.latitude IS NOT NULL')
                 .select(select_sql)
                 .order('course.id, distance_to_search_location ASC')

      Course
        .from(subquery, :course)
        .order('distance_to_search_location ASC')
    end

    private

    def select_sql
      <<~SQL.squish
        DISTINCT ON (course.id) course.id as course_id,
        course.*,
        site.id AS site_id,
        site.location_name,
        site.latitude,
        site.longitude,
        ST_DistanceSphere(
          ST_MakePoint(site.longitude::float, site.latitude::float),
          ST_MakePoint(#{Float(@longitude)}, #{Float(@latitude)})
        ) / 1609.34 AS distance_to_search_location
      SQL
    end
  end
end
