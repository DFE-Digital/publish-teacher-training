# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class LocationsIndex < PageObjects::Base
        set_url "/support/{recruitment_cycle_year}/providers/{provider_id}/locations"

        element :add_location, ".govuk-button", text: "Add location"

        sections :locations, Sections::Location, ".location-row"
      end
    end
  end
end
