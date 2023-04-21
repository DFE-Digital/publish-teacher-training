# frozen_string_literal: true

module CoursePreview
  class MissingInformationComponent < ViewComponent::Base
    attr_accessor :information_type, :course

    delegate :course_code, :recruitment_cycle_year, :provider_code, :accrediting_provider, to: :course

    def initialize(course:, information_type:)
      super
      @information_type = information_type
      @course = course
    end

    def text
      I18n.t("components.course_preview.missing_information.#{information_type}.text")
    end

    def link
      send("#{information_type}_link")
    end

    def render?
      FeatureService.enabled?(:course_preview_missing_information)
    end

    private

    def about_course_link = about_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def degree_link = degrees_start_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def fee_uk_eu_link = fees_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def gcse_link = gcses_pending_or_equivalency_tests_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def how_school_placements_work_link = "#{about_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)}#how-school-placements-work"
    def train_with_disability_link = "#{about_publish_provider_recruitment_cycle_path(provider_code, recruitment_cycle_year, course_code:, goto_preview: true)}#train-with-disability"
    def train_with_us_link = "#{about_publish_provider_recruitment_cycle_path(provider_code, recruitment_cycle_year, course_code:, goto_preview: true)}#train-with-us"
    def about_accrediting_provider_link = "#{about_publish_provider_recruitment_cycle_path(provider_code, recruitment_cycle_year, course_code:, goto_preview: true)}#accrediting-provider-#{accrediting_provider.provider_code}"
  end
end
