# frozen_string_literal: true

module PageObjects
  module Publish
    class ProviderAccreditedProvidersSearch < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/accredited-providers/search'

      element :search_input, '#accredited-provider-search-form-query-field'
      element :submit, 'input[type=submit]'
      element :continue_button, 'button[type=submit]'
      elements :choices, 'input[type=radio]'
    end
  end
end
