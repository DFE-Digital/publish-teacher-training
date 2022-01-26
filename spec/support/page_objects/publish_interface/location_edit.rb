# frozen_string_literal: true

require_relative "../sections/location_form"

module PageObjects
  module PublishInterface
    class LocationEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/locations/{location_id}/edit"
      element :error_summary, ".govuk-error-summary"

      section :location_form, Sections::LocationForm, ".location-form"

      element :name_field, "#publish-interface-location-form-location-name-field"
      element :address1_field, "#publish-interface-location-form-address1-field"
      element :postcode_field, "#publish-interface-location-form-postcode-field"

      element :submit, 'button.govuk-button[type="submit"]'

      def errors
        within(error_summary) do
          all(".govuk-error-summary__list li").map(&:text)
        end
      end
    end
  end
end
