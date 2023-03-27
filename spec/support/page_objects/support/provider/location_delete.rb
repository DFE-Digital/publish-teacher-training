# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class LocationDelete < PageObjects::Base
        set_url '/support/{recruitment_cycle_year}/providers/{provider_id}/locations/{id}/delete'

        element :heading, 'h1'
        element :warning_text, '.govuk-warning-text'
        element :cancel_link, '.govuk-link', text: 'Cancel'

        element :remove_location_button, '.govuk-button', text: 'Remove location'
      end
    end
  end
end
