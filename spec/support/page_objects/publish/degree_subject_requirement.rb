# frozen_string_literal: true

require_relative "../sections/errorlink"
require_relative "../sections/copy_content"

module PageObjects
  module Publish
    class DegreeSubjectRequirement < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/degrees/subject-requirements"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :copy_content_warning, '[data-qa="copy-course-warning"]'
      element :yes_radio, '[data-qa="degree_subject_requirements__yes_radio"]'
      element :no_radio, '[data-qa="degree_subject_requirements__no_radio"]'
      element :requirements, '[data-qa="degree_subject_requirements__requirements"]'
      element :use_content, '[data-qa="course__use_content"]'

      section :copy_content, Sections::CopyContent

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
