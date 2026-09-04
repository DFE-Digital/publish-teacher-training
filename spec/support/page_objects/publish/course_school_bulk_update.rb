# frozen_string_literal: true

module PageObjects
  module Publish
    class CourseSchoolBulkUpdate < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/schools/bulk-update/{state_key}"

      element :submit, 'button.govuk-button[type="submit"]'
      element :error_summary, ".govuk-error-summary"

      def scope_labels
        all(".govuk-radios__item label").map(&:text)
      end

      def divider_position
        all(".govuk-radios > *").index { |item| item[:class].to_s.include?("govuk-radios__divider") }
      end
    end
  end
end
