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
      section :engineers_teach_physics, Sections::SummaryList, '[data-qa="course__engineers_teach_physics"]'
      section :age_range, Sections::SummaryList, '[data-qa="course__age_range"]'
      section :outcome, Sections::SummaryList, '[data-qa="course__outcome"]'
      section :apprenticeship, Sections::SummaryList, '[data-qa="course__apprenticeship"]'
      section :funding, Sections::SummaryList, '[data-qa="course__funding"]'
      section :study_mode, Sections::SummaryList, '[data-qa="course__study_mode"]'
      section :schools, Sections::SummaryList, '[data-qa="course__schools"]'
      section :accredited_provider, Sections::SummaryList, '[data-qa="course__ratifying_provider"]'
      section :applications_open, Sections::SummaryList, '[data-qa="course__applications_open"]'
      section :start_date, Sections::SummaryList, '[data-qa="course__start_date"]'
      section :contact_support_link, Sections::SummaryList, '[data-qa="course__contact_support_link"]'
      section :course_button_panel, Sections::CourseButtonPanel, '[data-qa="course__button_panel"]'

      element :description_link, "a.govuk-link.govuk-tabs__tab", text: "Description"

      def change_link_texts
        all(".govuk-summary-list__actions .govuk-link .govuk-visually-hidden").map(&:text)
      end
    end
  end
end
