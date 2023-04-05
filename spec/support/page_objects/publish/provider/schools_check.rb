# frozen_string_literal: true

module PageObjects
  module Publish
    module Provider
      class SchoolsCheck < PageObjects::Base
        set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/schools/check'

        element :change_location_name, 'a.govuk-link.location_name', text: 'Change'
        element :change_urn, 'a.govuk-link.urn', text: 'Change'
        element :change_address, 'a.govuk-link.address', text: 'Change'

        element :add_location, '.govuk-button', text: 'Add school'
      end
    end
  end
end
