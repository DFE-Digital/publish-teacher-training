# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class LocationsCheck < PageObjects::Base
        set_url '/support/{recruitment_cycle_year}/providers/{provider_id}/locations/check'

        element :change_location_name, 'a.govuk-link.location_name', text: 'Change'
        element :change_urn, 'a.govuk-link.urn', text: 'Change'
        element :change_address, 'a.govuk-link.address', text: 'Change'

        element :add_location, '.govuk-button', text: 'Add location'
        element :add_another_location, '.govuk-button', text: 'Save location and add another'
      end
    end
  end
end
