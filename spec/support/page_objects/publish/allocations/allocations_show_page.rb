# frozen_string_literal: true

module PageObjects
  module Publish
    module Allocations
      class AllocationsShowPage < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/allocations/{provider_code}"

        element :page_heading, '[data-qa="page-heading"]'
      end
    end
  end
end
