# frozen_string_literal: true

require_relative '../sections/summary_list'
require_relative '../sections/error_link'
require_relative '../sections/course_button_panel'

module PageObjects
  module Publish
    class ProviderCoursesShow < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}'

      sections :errors, Sections::ErrorLink, '.govuk-error-summary__list li'

      section :about_course, Sections::SummaryList, '[data-qa="enrichment__about_course"]'
      section :interview_process, Sections::SummaryList, '[data-qa="enrichment__interview_process"]'
      section :how_school_placements_work, Sections::SummaryList, '[data-qa="enrichment__how_school_placements_work"]'
      section :fee_uk_eu, Sections::SummaryList, '[data-qa="enrichment__fee_uk_eu"]'
      section :fee_international, Sections::SummaryList, '[data-qa="enrichment__fee_international"]'
      section :fee_details, Sections::SummaryList, '[data-qa="enrichment__fee_details"]'
      section :course_length, Sections::SummaryList, '[data-qa="enrichment__course_length"]'
      section :financial_support, Sections::SummaryList, '[data-qa="enrichment__financial_support"]'
      section :financial_incentives, Sections::SummaryList, '[data-qa="course__financial_incentives"]'
      section :salary_details, Sections::SummaryList, '[data-qa="enrichment__salary_details"]'
      section :degree, Sections::SummaryList, '[data-qa="enrichment__degree_grade"]'
      section :gcse, Sections::SummaryList, '[data-qa="enrichment__accept_pending_gcse"]'
      section :a_level, Sections::SummaryList, '[data-qa="enrichment__a_level_requirements"]'
      section :course_button_panel, Sections::CourseButtonPanel, '[data-qa="course__button_panel"]'

      element :description_link, 'a.app-secondary-navigation__link', text: 'Description'
      element :basic_details_link, 'a.app-secondary-navigation__link', text: 'Basic details'
      element :content_status, '[data-qa="course__content-status"]'
      element :rolled_over_course_link, '[data-qa="course__rolled-over-link"]'
      element :publish_button, 'button[type=submit]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
