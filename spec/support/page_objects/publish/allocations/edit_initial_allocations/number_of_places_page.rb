module PageObjects
  module Publish
    module Allocations
      module EditInitialAllocations
        class NumberOfPlacesPage < PageObjects::Base
          set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/allocations/{provider_code}/edit_initial_allocations/number_of_places"

          element :header, "h1"
          element :number_of_places_field, "#number-of-places-field"
          element :continue, ".govuk-button", text: "Continue"
        end
      end
    end
  end
end
