# frozen_string_literal: true

module PageObjects
  module Publish
    class ProvidersIndex < PageObjects::Base
      set_url "/publish/organisations"

      element :admin_search_box, '[data-qa="admin-search-box"]'
      element :provider_list, '[data-qa="provider-list"]'
      element :pagination_pages, ".app-pagination__link-label"
      element :search_input, 'input[id="provider"]'
      element :search_button, '[data-qa="find-providers"]'

    end
  end
end
