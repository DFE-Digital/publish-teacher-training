# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class LocationShow < PageObjects::Base
        set_url '/support/{recruitment_cycle_year}/providers/{provider_id}/locations/{id}'

        element :change_name, 'a.govuk-link.location_name', text: 'Change'

        element :remove_school_link, '.govuk-link', text: 'Remove location'
      end
    end
  end
end
