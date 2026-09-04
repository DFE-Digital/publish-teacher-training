# frozen_string_literal: true

module Publish
  class CourseSchoolForm < BaseCourseForm
    FIELDS = %i[school_uuids schools_validated].freeze

    attr_accessor(*FIELDS)

    validate :no_schools_selected
    validate :school_uuids_belong_to_provider

    def compute_fields
      { school_uuids: attached_school_uuids }.merge(new_attributes)
    end

    # The schools on the course as it stands. It seeds the ticked boxes, and the
    # page also hands it to the browser as what the provider's changes are
    # measured against.
    def attached_school_uuids
      @attached_school_uuids ||= course.schools.joins(:provider_school).pluck("provider_school.uuid")
    end

    # Every school the provider could attach, in the order they are listed.
    def schools
      @schools ||= SchoolsList.for(course.provider)
    end

    def schools_collapse_threshold
      SchoolsList::COLLAPSE_AFTER
    end

    def collapse_schools?
      schools.size > schools_collapse_threshold
    end

  private

    def no_schools_selected
      return if params[:school_uuids].present?
      return if ::Courses::PublishRules::SchoolPresenceExemption.applies?(course)

      if course.recruitment_cycle_rollover_period_2026?
        error = course.schools.exists? ? :check_schools : :enter_schools
        errors.add(:school_uuids, error)
      else
        errors.add(:school_uuids, :no_schools)
      end
    end

    def school_uuids_belong_to_provider
      school_uuids = Array(params[:school_uuids]).compact_blank.uniq
      return if school_uuids.empty?

      known_school_uuids = provider_schools
        .where(uuid: school_uuids)
        .pluck("provider_school.uuid")
      return if (school_uuids - known_school_uuids).empty?

      errors.add(:school_uuids, :school_uuids_invalid)
    end

    # Rollover controls which schools exist for the cycle. Once a
    # Provider::School exists, it can be attached regardless of GIAS status.
    def provider_schools
      course.provider.schools.joins(:gias_school)
    end
  end
end
