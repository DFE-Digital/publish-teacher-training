# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class CourseInformationEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/about"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :about_course, "#publish-course-information-form-about-course-field"
      element :interview_process, "#publish-course-information-form-interview-process-field"
      element :school_placements, "#publish-course-information-form-how-school-placements-work-field"

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
