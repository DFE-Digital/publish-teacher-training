# frozen_string_literal: true

require_relative "../sections/summary_list"
require_relative "../sections/errorlink"
require_relative "../sections/course_button_panel"

module PageObjects
  module Publish
    class ProviderCoursesShow < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li"

      section :about_course, Sections::SummaryList, '[data-qa="enrichment__about_course"]'
      section :interview_process, Sections::SummaryList, '[data-qa="enrichment__interview_process"]'
      section :how_school_placements_work, Sections::SummaryList, '[data-qa="enrichment__how_school_placements_work"]'
      section :fee_uk_eu, Sections::SummaryList, '[data-qa="enrichment__fee_uk_eu"]'
      section :fee_international, Sections::SummaryList, '[data-qa="enrichment__fee_international"]'
      section :fee_details, Sections::SummaryList, '[data-qa="enrichment__fee_details"]'
      section :course_length, Sections::SummaryList, '[data-qa="enrichment__course_length"]'
      section :financial_support, Sections::SummaryList, '[data-qa="enrichment__financial_support"]'
      section :salary_details, Sections::SummaryList, '[data-qa="enrichment__salary_details"]'
      section :degree, Sections::SummaryList, '[data-qa="enrichment__degree_grade"]'
      section :gcse, Sections::SummaryList, '[data-qa="enrichment__accept_pending_gcse"]'
      section :personal_qualities, Sections::SummaryList, '[data-qa="enrichment__personal_qualities"]'
      section :other_requirements, Sections::SummaryList, '[data-qa="enrichment__other_requirements"]'
      section :course_button_panel, Sections::CourseButtonPanel, '[data-qa="course__button_panel"]'

      element :basic_details_link, "a.govuk-link.govuk-tabs__tab", text: "Basic details"
      element :content_status, '[data-qa="course__content-status"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
