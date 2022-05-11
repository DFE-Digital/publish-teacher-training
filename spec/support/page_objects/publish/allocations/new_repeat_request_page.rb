# frozen_string_literal: true

module PageObjects
  module Publish
    module Allocations
      class NewRepeatRequestPage < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/allocations/{training_provider_code}/new-repeat-request"

        element :header, "h1"

        element :yes, "#request-type-repeat-field"
        element :no, "#request-type-declined-field"

        element :continue_button, '[data-qa="allocations__continue"]'
      end
    end
  end
end
