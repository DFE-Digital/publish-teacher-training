# frozen_string_literal: true

# Removes Course::School rows for a course/provider_school. Idempotent:
# destroy_all on an empty relation is a no-op, matching the "safe to
# re-run" semantics of the schools backfill.
module CourseSchools
  class Remover
    include ServicePattern

    def initialize(course:, provider_school: nil, provider_school_id: nil, gias_school_id: nil)
      @course = course
      @provider_school = provider_school
      @provider_school_id = provider_school_id
      @gias_school_id = gias_school_id
    end

    def call
      @course.schools.where(removal_scope).destroy_all
    end

  private

    def removal_scope
      return { provider_school_id: @provider_school.id } if @provider_school.present?
      return { provider_school_id: @provider_school_id } if @provider_school_id.present?

      { gias_school_id: @gias_school_id }
    end
  end
end
