# frozen_string_literal: true

# Writes a Course::School row linking a course to one of its provider's
# Provider::School records. Idempotent under RecordNotUnique (race with a
# backfill run or another request).
#
# Keyed on the Provider::School rather than the GIAS school: the
# provider_school unique index is (provider_id, gias_school_id, site_code),
# so a provider may hold the same GIAS school under two site codes and
# gias_school_id alone does not identify a row.
module CourseSchools
  class Creator
    include ServicePattern

    def initialize(course:, provider_school:)
      @course = course
      @provider_school = provider_school
    end

    def call
      # Key on provider_school_id to match the (course_id, provider_school_id)
      # unique index; copy gias_school_id from the provider_school so the
      # denormalised column can never disagree with it.
      @course.schools.find_or_create_by!(provider_school_id: @provider_school.id) do |course_school|
        course_school.gias_school_id = @provider_school.gias_school_id
      end
    rescue ActiveRecord::RecordNotUnique
      @course.schools.find_by!(provider_school_id: @provider_school.id)
    end
  end
end
