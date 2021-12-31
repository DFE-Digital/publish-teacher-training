# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class LocationEdit < PageObjects::Base
        set_url "/support/providers/{provider_id}/locations/{location_id}/edit"
        element :error_summary, ".govuk-error-summary"

        element :location_name, "#site-location-name-field"
        element :urn, "#site-urn-field"
        element :code, "#site-code-field"
        element :building_and_street, "#site-address1-field"
        element :postcode, "#site-postcode-field"

        element :update_record, 'button.govuk-button[type="submit"]'
        element :delete_record, 'input.govuk-button[type="submit"]'

        def errors
          within(error_summary) do
            all(".govuk-error-summary__list li").map(&:text)
          end
        end
      end
    end
  end
end
