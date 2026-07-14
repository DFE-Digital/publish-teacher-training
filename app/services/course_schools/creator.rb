# frozen_string_literal: true

# Writes a Course::School row for a course from a Provider::School. Idempotent
# under RecordNotUnique (race with a backfill run or another request).
module CourseSchools
  class Creator
    include ServicePattern

    def initialize(course:, provider_school: nil, provider_school_id: nil, gias_school_id: nil, site_code: nil)
      @course = course
      @provider_school = provider_school
      @provider_school_id = provider_school_id
      @gias_school_id = gias_school_id
      @site_code = site_code
    end

    def call
      provider_school = resolved_provider_school

      @course.schools.find_or_create_by!(provider_school_id: provider_school.id) do |course_school|
        course_school.gias_school_id = provider_school.gias_school_id
      end
    rescue ActiveRecord::RecordNotUnique
      @course.schools.find_by!(provider_school_id: provider_school.id)
    rescue ActiveRecord::RecordNotFound, ArgumentError => e
      log_skipped_write(e)
      nil
    end

  private

    def resolved_provider_school
      return @provider_school if @provider_school.present?
      return @course.provider.schools.find(@provider_school_id) if @provider_school_id.present?
      return @course.provider.schools.find_by!(gias_school_id: @gias_school_id, site_code: @site_code) if @gias_school_id.present? && @site_code.present?

      raise ArgumentError, "provider_school, provider_school_id, or gias_school_id with site_code must be provided"
    end

    def log_skipped_write(error)
      Rails.logger.warn(
        "[CourseSchools] skipped course_school write — #{error.class}: #{error.message} " \
        "course=#{@course.id} provider=#{@course.provider_id} " \
        "provider_school_id=#{@provider_school_id.inspect} " \
        "gias_school_id=#{@gias_school_id.inspect} site_code=#{@site_code.inspect}",
      )
    end
  end
end
