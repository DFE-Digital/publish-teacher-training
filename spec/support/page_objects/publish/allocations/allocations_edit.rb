# frozen_string_literal: true

module PageObjects
  module Publish
    module Allocations
      class AllocationsEdit < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/allocations/{provider_code}/edit{?query*}"

        element :header, "h1"

        element :yes, "#request-type-repeat-field"
        element :no, "#request-type-declined-field"

        element :continue_button, '[data-qa="allocations__continue"]'
      end
    end
  end
end
