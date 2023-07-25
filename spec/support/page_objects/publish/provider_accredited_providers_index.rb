# frozen_string_literal: true

module PageObjects
  module Publish
    class ProviderAccreditedProvidersIndex < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/accredited-providers'

      element :add_new_link, '[data-qa="add-accredited-provider-link"]'
      elements :remove, '[data-qa="remove-link"]'
    end
  end
end
