# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class CourseRequirementEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/requirements"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :required_qualifications, "#publish-course-requirement-form-required-qualifications-field"
      element :personal_qualities, "#publish-course-requirement-form-personal-qualities-field"
      element :other_requirements, "#publish-course-requirement-form-other-requirements-field"

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
