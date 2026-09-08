# frozen_string_literal: true

module PageObjects
  module Publish
    class TrainingPartnerCourses < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/training-partners/{training_partner_code}/courses"

      elements :column_headings, ".app-table--courses .govuk-table__header"

      sections :rows, ".app-table--courses tbody tr" do
        element :name, ".app-table--courses__course-name"
        element :course_information, ".app-table--courses__course-information"
        element :status, ".app-table--courses__status"
        element :view_course, ".app-table--courses__view-course"
      end
    end
  end
end
