# frozen_string_literal: true

# Removes the Course::School row for (course, provider_school). Idempotent:
# destroy_all on an empty relation is a no-op, matching the "safe to
# re-run" semantics of the schools backfill.
#
# Keyed on the Provider::School rather than the GIAS school: a provider may
# hold the same GIAS school under two site codes, and keying on
# gias_school_id would detach both.
module CourseSchools
  class Remover
    include ServicePattern

    def initialize(course:, provider_school:)
      @course = course
      @provider_school = provider_school
    end

    def call
      @course.schools.where(provider_school_id: @provider_school.id).destroy_all
    end
  end
end
