# frozen_string_literal: true

module Publish
  class CourseSchoolForm < BaseCourseForm
    FIELDS = %i[school_uuids schools_validated].freeze

    attr_accessor(*FIELDS)

    validate :no_schools_selected

    # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
    # TODO School data remodel removal - replace course.sites with course.schools/provider_schools when Site is retired for schools.
    def compute_fields
      { school_uuids: schools_identity.current_school_uuids }.merge(new_attributes)
    end

    # Every school the provider could attach, in the order they are listed.
    def sites
      @sites ||= schools_identity.available_schools
    end

    def schools_collapse_threshold
      SchoolsList::COLLAPSE_AFTER
    end

    def collapse_schools?
      sites.size > schools_collapse_threshold
    end

  private

    # TODO School data remodel removal - remove Site-based rollover checks when school presence is fully based on Course::School.
    def no_schools_selected
      return if params[:school_uuids].present?
      return if ::Courses::PublishRules::SchoolPresenceExemption.applies?(course)

      if course.recruitment_cycle_rollover_period_2026?
        errors.add(:school_uuids, :check_schools) if schools_identity.current_school_uuids.present?
        errors.add(:school_uuids, :enter_schools) if schools_identity.current_school_uuids.blank?
      else
        errors.add(:school_uuids, :no_schools)
      end
    end

    def schools_identity
      @schools_identity ||= ::CourseSchools::Identity.new(provider: course.provider, course:)
    end
    # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
  end
end
