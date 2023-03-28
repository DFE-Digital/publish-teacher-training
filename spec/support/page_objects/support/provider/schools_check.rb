# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class SchoolsCheck < PageObjects::Base
        set_url '/support/{recruitment_cycle_year}/providers/{provider_id}/schools/check'

        element :change_school_name, 'a.govuk-link.school_name', text: 'Change'
        element :change_urn, 'a.govuk-link.urn', text: 'Change'
        element :change_address, 'a.govuk-link.address', text: 'Change'

        element :add_school, '.govuk-button', text: 'Add school'
        element :add_another_school, '.govuk-button', text: 'Save school and add another'
      end
    end
  end
end
