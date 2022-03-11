# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class DegreeGrade < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/degrees/grade"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :two_one, '[data-qa="degree_grade__two_one"]'
      element :two_two, '[data-qa="degree_grade__two_two"]'
      element :third_class, '[data-qa="degree_grade__third_class"]'

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
