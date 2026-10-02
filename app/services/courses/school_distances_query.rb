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
    include CanonicalSchoolDistance

    def initialize(courses:, latitude:, longitude:)
      @courses = courses
      @latitude = latitude
      @longitude = longitude
    end

    def call
      schools_query
    end

  private

    # Every school of every course over course_school -> gias_school.
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
                 .where(GEOCODED_SCHOOL)
                 .select(school_columns_sql(EACH_SCHOOL_PER_COURSE))
                 .order("course.id, gias_school.id, provider_school.site_code ASC")

      # Course ignores columns, so without this select Rails lists only the
      # Course columns and drops the subquery's extra columns.
      Course
        .select("course.*")
        .from(subquery, :course)
        .order("course_id ASC, distance_to_search_location ASC")
    end
  end
end
