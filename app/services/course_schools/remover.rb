# frozen_string_literal: true

# Removes the Course::School row for (course, gias_school). Idempotent:
# destroy_all on an empty relation is a no-op, matching the "safe to
# re-run" semantics of the schools backfill.
module CourseSchools
  class Remover
    include ServicePattern

    def initialize(course:, gias_school_id:)
      @course = course
      @gias_school_id = gias_school_id
    end

    def call
      @course.schools.where(gias_school_id: @gias_school_id).destroy_all
    end
  end
end
