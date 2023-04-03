# frozen_string_literal: true

module CoursePreview
  class MissingInformationComponent < ViewComponent::Base
    attr_accessor :information_type, :course

    delegate :course_code, :recruitment_cycle_year, :provider_code, to: :course

    def initialize(course:, information_type:)
      super
      @information_type = information_type
      @course = course
    end

    def text
      I18n.t("components.course_preview.missing_information.#{information_type}.text")
    end

    def link
      {
        about_course: about_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
        degree: degrees_start_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
        fee_uk_eu: fees_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
        gcse: gcses_pending_or_equivalency_tests_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true),
        how_school_placements_work: "#{about_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)}#how-school-placements-work"
      }[information_type]
    end

    def render?
      FeatureService.enabled?(:course_preview_missing_information)
    end
  end
end
