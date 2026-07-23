# frozen_string_literal: true

module Publish
  class CourseSchoolForm < BaseCourseForm
    FIELDS = %i[school_uuids schools_validated].freeze

    attr_accessor(*FIELDS)

    validate :no_schools_selected

    def compute_fields
      { school_uuids: course.sites.map { |site| site.uuid.to_s } }.merge(new_attributes)
    end

    # Every school the provider could attach, in the order they are listed.
    def sites
      @sites ||= course.provider.sites.order(:location_name).to_a
    end

    def schools_collapse_threshold
      SchoolsList::COLLAPSE_AFTER
    end

    def collapse_schools?
      sites.size > schools_collapse_threshold
    end

  private

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
  end
end
