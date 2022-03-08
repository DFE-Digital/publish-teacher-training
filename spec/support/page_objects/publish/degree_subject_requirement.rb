# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class DegreeSubjectRequirement < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/degrees/subject-requirements"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :yes_radio, '[data-qa="degree_subject_requirements__yes_radio"]'
      element :no_radio, '[data-qa="degree_subject_requirements__no_radio"]'
      element :requirements, '[data-qa="degree_subject_requirements__requirements"]'

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
