# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class DegreeStart < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/degrees/start"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :yes_radio, '[data-qa="start__yes_radio"]'
      element :no_radio, '[data-qa="start__no_radio"]'

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
