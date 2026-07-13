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

      # Key on provider_school_id to match the (course_id, provider_school_id)
      # unique index; copy gias_school_id and site_code from the provider_school
      # so the denormalised columns can never disagree with it.
      @course.schools.find_or_create_by!(provider_school_id: provider_school.id) do |course_school|
        course_school.gias_school_id = provider_school.gias_school_id
        course_school.site_code = provider_school.site_code
      end
    rescue ActiveRecord::RecordNotUnique
      @course.schools.find_by!(provider_school_id: provider_school.id)
    end
  end
end
