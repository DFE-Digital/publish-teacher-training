# frozen_string_literal: true

module PageObjects
  module Publish
    class ProvidersIndex < PageObjects::Base
      set_url "/publish/organisations"

      element :admin_search_box, '[data-qa="admin-search-box"]'
      element :provider_list, '[data-qa="provider-list"]'

      # def providers
      #   page.find_all(".qa-provider_row")
      # end
    end
  end
end