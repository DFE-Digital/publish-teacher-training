# frozen_string_literal: true

require_relative '../sections/school_form'

module PageObjects
  module Publish
    class SchoolEdit < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/schools/{school_id}/edit'
      element :error_summary, '.govuk-error-summary'

      section :school_form, Sections::SchoolForm, '.school-form'

      element :name_field, '#publish-school-form-location-name-field'
      element :address1_field, '#publish-school-form-address1-field'
      element :postcode_field, '#publish-school-form-postcode-field'

      element :submit, 'button.govuk-button[type="submit"]'

      def errors
        within(error_summary) do
          all('.govuk-error-summary__list li').map(&:text)
        end
      end
    end
  end
end
