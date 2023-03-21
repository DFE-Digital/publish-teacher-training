# frozen_string_literal: true

require_relative '../sections/school'

module PageObjects
  module Publish
    class SchoolsIndex < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/schools'

      sections :schools, Sections::School, '.location-row'

      element :add_school, '.govuk-button', text: 'Add school'
    end
  end
end
