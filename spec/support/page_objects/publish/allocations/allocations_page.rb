# frozen_string_literal: true

require_relative "../../sections/errorlink"

module PageObjects
  module Publish
    module Allocations
      class AllocationsPage < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/allocations"

        sections :rows, "tbody tr" do
          element :provider_name, '[data-qa="provider-name"]'
          element :status, "td[:nth-child(1)"
          element :actions, "td[:nth-child(2)"
          element :allocation_number, '[data-qa="confirmed-places"]'
          element :uplift_number, '[data-qa="uplifts"]'
        end
      end
    end
  end
end
