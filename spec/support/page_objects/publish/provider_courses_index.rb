# frozen_string_literal: true

require_relative "../sections/course"

module PageObjects
  module Publish
    class ProviderCoursesIndex < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses"

      sections :courses, '[data-qa="courses__table-section"]' do
        element :subheading, "h2"
        element :name, '[data-qa="courses-table__course-name"]'
        element :link, '[data-qa="courses-table__course-name"] a'
        element :status, '[data-qa="courses-table__status"]'
        element :on_find, '[data-qa="courses-table__findable"]'
        element :find_link, '[data-qa="courses-table__findable"] a'
        element :applications, '[data-qa="courses-table__applications"]'
        element :vacancies, '[data-qa="courses-table__vacancies"]'
      end

      element :success_summary, ".govuk-notification-banner--success"

      element :add_course, ".govuk-button", text: "Add course"

      element :scheduled, ".govuk-tag--blue", text: "Scheduled"
    end
  end
end
