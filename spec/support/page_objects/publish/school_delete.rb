# frozen_string_literal: true

module PageObjects
  module Publish
    class SchoolDelete < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/schools/{school_id}/delete'

      element :heading, 'h1'
      # element :warning_text, '.govuk-warning-text'
      element :cancel_link, '.govuk-link', text: 'Cancel'

      element :remove_school_button, '.govuk-button', text: 'Remove school'
    end
  end
end
