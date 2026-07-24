# frozen_string_literal: true

module Publish
  class CourseSchoolForm < BaseCourseForm
    FIELDS = %i[school_uuids schools_validated].freeze

    attr_accessor(*FIELDS)

    validate :no_schools_selected
    validate :school_uuids_belong_to_provider

    def compute_fields
      { school_uuids: current_school_uuids }.merge(new_attributes)
    end

    # Every school the provider could attach, in the order they are listed.
    def schools
      @schools ||= ProviderSchools::Identity.ordered_school_scope(provider: course.provider)
    end

    def schools_collapse_threshold
      SchoolsList::COLLAPSE_AFTER
    end

    def collapse_schools?
      schools.size > schools_collapse_threshold
    end

  private

    def current_school_uuids
      if after_schools_remodel_cycle?
        course.schools.includes(:provider_school).map { |course_school| course_school.provider_school.uuid }
      else
        course.sites.map(&:uuid)
      end
    end

    def no_schools_selected
      return if params[:school_uuids].present?
      return if ::Courses::PublishRules::SchoolPresenceExemption.applies?(course)

      if course.recruitment_cycle_rollover_period_2026?
        errors.add(:school_uuids, :check_schools) if course.sites.school.present?
        errors.add(:school_uuids, :enter_schools) if course.sites.school.blank?
      else
        errors.add(:school_uuids, :no_schools)
      end
    end

    def school_uuids_belong_to_provider
      school_uuids = Array(params[:school_uuids]).compact_blank.uniq
      return if school_uuids.empty?

      known_school_uuids = school_scope.where(uuid: school_uuids).pluck(:uuid)
      return if (school_uuids - known_school_uuids).empty?

      errors.add(:school_uuids, :school_uuids_invalid)
    end

    def school_scope
      if after_schools_remodel_cycle?
        course.provider.schools
      else
        course.provider.sites
      end
    end

    def after_schools_remodel_cycle?
      course.recruitment_cycle.after?(Settings.schools_remodel_cycle_year)
    end
  end
end
