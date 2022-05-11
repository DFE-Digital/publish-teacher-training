module PageObjects
  module Publish
    module Allocations
      module EditInitialAllocations
        class DoYouWantPage < PageObjects::Base
          set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/allocations/{provider_code}/edit_initial_allocations/do_you_want"

          element :header, "h1"
          element :yes, "#request-type-initial-field"
          element :no, "#request-type-declined-field"
          element :continue, ".govuk-button", text: "Continue"
        end
      end
    end
  end
end
