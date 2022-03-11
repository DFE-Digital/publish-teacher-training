# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class CourseStudyModeEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/full-part-time"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :full_time, "#publish-course-study-mode-form-study-mode-full-time-field"
      element :part_time, "#publish-course-study-mode-form-study-mode-part-time-field"
      element :full_or_part_time, "#publish-course-study-mode-form-study-mode-full-time-or-part-time-field"

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
