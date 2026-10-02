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
      Course
        .select("course.*")
        .from(schools_subquery, :course)
        .order("distance_to_search_location ASC")
    end

  private

    # Nearest school over course_school -> gias_school.
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
  end
end
