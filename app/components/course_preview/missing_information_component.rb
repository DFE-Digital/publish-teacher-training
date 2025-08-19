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
    def school_placement_link = fields_school_placement_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def what_you_will_study_link = fields_what_you_will_study_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def interview_process_link = fields_interview_process_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def fees_and_financials_link = fields_fees_and_financial_support_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def financial_support_link = fields_fees_and_financial_support_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def where_you_will_train_link = fields_where_you_will_train_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code, goto_preview: true)
    def provider_train_with_disability_link = edit_publish_provider_recruitment_cycle_disability_support_path(provider_code, recruitment_cycle_year, course_code:, goto_training_with_disabilities: true)

    def train_with_us_link
      if FeatureFlag.active?(:long_form_content) || Current.recruitment_cycle.after_2025?
        edit_publish_provider_recruitment_cycle_why_train_with_us_path(provider_code, recruitment_cycle_year, course_code:, goto_provider: true)
      else
        about_publish_provider_recruitment_cycle_path(provider_code, recruitment_cycle_year, course_code:, goto_provider: true, anchor: "train-with-us")
      end
    end

    def train_with_disability_link
      if FeatureFlag.active?(:long_form_content) || Current.recruitment_cycle.after_2025?
        edit_publish_provider_recruitment_cycle_disability_support_path(provider_code, recruitment_cycle_year, course_code:, goto_training_with_disabilities: true)
      else
        about_publish_provider_recruitment_cycle_path(provider_code, recruitment_cycle_year, course_code:, goto_training_with_disabilities: true, anchor: "train-with-disability")
      end
    end
  end
end
