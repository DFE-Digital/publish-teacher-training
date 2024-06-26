# frozen_string_literal: true

require_relative '../sections/school_form'

module PageObjects
  module Publish
    class SchoolNew < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/schools/new'
      element :error_summary, '.govuk-error-summary'

      element :name_field, '#support-school-form-location-name-field'
      element :address1_field, '#support-school-form-address1-field'
      element :town_field, '#support-school-form-town-field'
      element :postcode_field, '#support-school-form-postcode-field'

      element :submit, 'button.govuk-button[type="submit"]'

      def errors
        within(error_summary) do
          all('.govuk-error-summary__list li').map(&:text)
        end
      end
    end
  end
end
