# frozen_string_literal: true

module CoursePreview
  class MissingInformationComponent < ViewComponent::Base
    attr_reader :information_type, :course, :is_preview

    delegate :course_code, :recruitment_cycle_year, :provider_code, :accrediting_provider, to: :course

    def initialize(course:, information_type:, is_preview:)
      super
      @information_type = information_type
      @course = course
      @is_preview = is_preview
    end

    def text
      I18n.t("components.course_preview.missing_information.#{information_type}.text")
    end

    def link
      send("#{information_type}_link")
    end

    def render?
      is_preview
    end

    def accrediting_provider_present?(course)
      course.provider.accredited_partners.include?(course.accrediting_provider)
    end

  private

    def about_this_course_link = about_this_course_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def degree_link = degrees_start_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def fee_uk_eu_link = fees_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def gcse_link = gcses_pending_or_equivalency_tests_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def how_school_placements_work_link = school_placements_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def train_with_disability_link = about_publish_provider_recruitment_cycle_path(provider_code, recruitment_cycle_year, course_code:, goto_training_with_disabilities: true, anchor: "train-with-disability")
    def train_with_us_link = about_publish_provider_recruitment_cycle_path(provider_code, recruitment_cycle_year, course_code:, goto_provider: true, anchor: "train-with-us")
  end
end
