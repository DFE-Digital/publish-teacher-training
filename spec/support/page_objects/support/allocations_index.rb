# frozen_string_literal: true

module PageObjects
  module Support
    class AllocationsIndex < PageObjects::Base
      set_url "/support/allocations"

      # Filter elements
      element :apply_filters, "input.govuk-button"
      element :text_search, "#text_search.govuk-input"
      element :remove_filters, "a.govuk-link", text: "Clear"

      def providers
        page.find_all(".qa-provider_row")
      end
    end
  end
end
