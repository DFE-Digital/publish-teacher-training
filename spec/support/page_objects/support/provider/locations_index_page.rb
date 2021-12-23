# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class LocationsIndex < PageObjects::Base
        set_url "/support/providers/{provider_id}/locations"

        sections :locations, Sections::Location, ".location-row"
      end
    end
  end
end
