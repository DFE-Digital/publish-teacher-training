# frozen_string_literal: true

require_relative "../sections/error_link"

module PageObjects
  module Publish
    class CourseStudyModeEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/full-part-time"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :full_time, '[value="full_time"]'
      element :part_time, '[value="part_time"]'

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
