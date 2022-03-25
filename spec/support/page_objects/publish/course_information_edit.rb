# frozen_string_literal: true

require_relative "../sections/errorlink"
require_relative "../sections/related_sidebar"
require_relative "../sections/copy_content"

module PageObjects
  module Publish
    class CourseInformationEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/about"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :copy_content_warning, '[data-qa="copy-course-warning"]'
      element :about_course, "#publish-course-information-form-about-course-field"
      element :interview_process, "#publish-course-information-form-interview-process-field"
      element :school_placements, "#publish-course-information-form-how-school-placements-work-field"
      element :use_content, '[data-qa="course__use_content"]'
      element :submit, 'button.govuk-button[type="submit"]'

      section :copy_content, Sections::CopyContent

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
