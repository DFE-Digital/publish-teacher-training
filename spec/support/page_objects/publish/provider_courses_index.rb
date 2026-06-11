# frozen_string_literal: true

require_relative "../sections/course"

module PageObjects
  module Publish
    class ProviderCoursesIndex < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses"

      sections :courses, ".app-course-list__group" do
        element :subheading, "h2"
        element :name, ".app-table--courses__course-name"
        element :link, ".app-table--courses__course-name a"
        element :course_information, ".app-table--courses__course-information"
        element :status, ".app-table--courses__status"
      end

      element :success_summary, ".govuk-notification-banner--success"

      element :add_course, ".govuk-button", text: "Add course"

      element :scheduled_tag, ".govuk-tag--blue", text: "Scheduled"
    end
  end
end
