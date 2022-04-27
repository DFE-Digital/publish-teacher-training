# frozen_string_literal: true

module PageObjects
  module Publish
    module Allocations
      module Request
        class PickAProviderPage < PageObjects::Base
          set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/allocations/request"

          element :header, "h1"

          sections :providers, ".govuk-list li" do
            element :link, "a"
          end
        end
      end
    end
  end
end
