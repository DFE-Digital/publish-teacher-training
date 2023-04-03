# frozen_string_literal: true

module PageObjects
  module Publish
    class SchoolShow < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/schools/{school_id}'

      element :change_name, 'a.govuk-link.location_name', text: 'Change'

      element :remove_school_link, '.govuk-link', text: 'Remove school'
    end
  end
end
