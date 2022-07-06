# frozen_string_literal: true

require_relative "../sections/summary_list"
require_relative "../sections/course_button_panel"

module PageObjects
  module Publish
    class ProviderCoursesDetails < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/details"

      section :about_course, Sections::SummaryList, '[data-qa="enrichment__about_course"]'
      section :level, Sections::SummaryList, '[data-qa="course__level"]'
      section :is_send, Sections::SummaryList, '[data-qa="course__is_send"]'
      section :subjects, Sections::SummaryList, '[data-qa="course__subjects"]'
      section :age_range, Sections::SummaryList, '[data-qa="course__age_range"]'
      section :outcome, Sections::SummaryList, '[data-qa="course__outcome"]'
      section :apprenticeship, Sections::SummaryList, '[data-qa="course__apprenticeship"]'
      section :funding, Sections::SummaryList, '[data-qa="course__funding"]'
      section :study_mode, Sections::SummaryList, '[data-qa="course__study_mode"]'
      section :locations, Sections::SummaryList, '[data-qa="course__locations"]'
      section :accredited_body, Sections::SummaryList, '[data-qa="course__accredited_body"]'
      section :applications_open, Sections::SummaryList, '[data-qa="course__applications_open"]'
      section :start_date, Sections::SummaryList, '[data-qa="course__start_date"]'
      section :name, Sections::SummaryList, '[data-qa="course__name"]'
      section :description, Sections::SummaryList, '[data-qa="course__description"]'
      section :course_code, Sections::SummaryList, '[data-qa="course__course_code"]'
      section :allocations, Sections::SummaryList, '[data-qa="course__allocations"]'
      section :contact_support_link, Sections::SummaryList, '[data-qa="course__contact_support_link"]'
      section :course_button_panel, Sections::CourseButtonPanel, '[data-qa="course__button_panel"]'

      element :description_link, "a.govuk-link.govuk-tabs__tab", text: "Description"
    end
  end
end
