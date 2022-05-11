# frozen_string_literal: true

module PageObjects
  module Publish
    module Allocations
      module Request
        class NumberOfPlacesPage < PageObjects::Base
          set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/allocations/request"

          element :header, "h1"
          element :number_of_places_field, "#number-of-places-field"
          element :continue, ".govuk-button"
        end
      end
    end
  end
end
