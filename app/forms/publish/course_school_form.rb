# frozen_string_literal: true

module Publish
  class CourseSchoolForm < BaseCourseForm
    FIELDS = %i[school_uuids schools_validated].freeze

    attr_accessor(*FIELDS)

    validate :no_schools_selected

    def compute_fields
      { school_uuids: identity.current_school_uuids }.merge(new_attributes)
    end

    # Every school the provider could attach, ordered by GIAS school name.
    def schools
      @schools ||= identity.available_schools.to_a
    end

    def schools_collapse_threshold
      SchoolsList::COLLAPSE_AFTER
    end

    def collapse_schools?
      schools.size > schools_collapse_threshold
    end

    # Whether the list still contains a school the phase filter would have
    # hidden, which the callout copy has to account for.
    delegate :out_of_phase_schools?, to: :identity

  private

    def identity
      @identity ||= ::CourseSchools::Identity.new(provider: course.provider, course:)
    end

    def no_schools_selected
      return if params[:school_uuids].present?
      return if ::Courses::PublishRules::SchoolPresenceExemption.applies?(course)

      if course.recruitment_cycle_rollover_period_2026?
        # Which variant to show depends on whether the provider is being asked
        # to confirm schools they can see or to add their first, so it reads
        # the same list the page rendered.
        if identity.current_school_uuids.any?
          errors.add(:school_uuids, :check_schools)
        else
          errors.add(:school_uuids, :enter_schools)
        end
      else
        errors.add(:school_uuids, :no_schools)
      end
    end
  end
end
