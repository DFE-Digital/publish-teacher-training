# frozen_string_literal: true

require_relative "../sections/school_form"

module PageObjects
  module Publish
    class SchoolNew < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/schools/new"
      element :error_summary, ".govuk-error-summary"

      element :submit, 'button.govuk-button[type="submit"]'

      def errors
        within(error_summary) do
          all(".govuk-error-summary__list li").map(&:text)
        end
      end
    end
  end
end
