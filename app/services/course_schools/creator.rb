# frozen_string_literal: true

# Writes a Course::School row for a course, copying site_code from the
# matching Provider::School for (course.provider, gias_school). Idempotent
# under RecordNotUnique (race with a backfill run or another request).
# Raises ActiveRecord::RecordNotFound if no Provider::School exists for
# the pair — callers are expected to run inside a transaction so the
# failure rolls back any legacy write paired with this one.
module CourseSchools
  class Creator
    include ServicePattern

    def initialize(course:, gias_school_id:)
      @course = course
      @gias_school_id = gias_school_id
    end

    def call
      provider_school = @course.provider.schools.find_by!(gias_school_id: @gias_school_id)

      @course.schools.find_or_create_by!(gias_school_id: @gias_school_id) do |course_school|
        course_school.site_code = provider_school.site_code
      end
    rescue ActiveRecord::RecordNotUnique
      @course.schools.find_by!(gias_school_id: @gias_school_id)
    end
  end
end
