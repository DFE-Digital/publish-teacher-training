# frozen_string_literal: true

module Courses
  # This query class fetches distances between given courses' sites and a specified location.
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
      Course
        .joins(site_statuses: :site)
        .where(id: @courses.map(&:id))
        .where('site.longitude IS NOT NULL AND site.latitude IS NOT NULL')
        .select(select_sql)
        .order('course.id, distance_to_search_location ASC')
        .group('course.id, site.id')
    end

    private

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
