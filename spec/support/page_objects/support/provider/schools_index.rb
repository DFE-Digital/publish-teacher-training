# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class SchoolsIndex < PageObjects::Base
        set_url '/support/{recruitment_cycle_year}/providers/{provider_id}/schools'

        element :add_school, '.govuk-button', text: 'Add school'

        sections :schools, Sections::School, '.school-row'
      end
    end
  end
end
