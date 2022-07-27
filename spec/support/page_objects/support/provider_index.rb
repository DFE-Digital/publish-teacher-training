# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderIndex < PageObjects::Base
      set_url "/support/{recruitment_cycle_year}/providers"

      # Filter elements
      element :apply_filters, "input.govuk-button"
      element :provider_name_or_code_search, "#provider_search.govuk-input"
      element :course_code_search, "#course_search.govuk-input"
      element :remove_filters, "a.govuk-link", text: "Clear"

      def providers
        page.find_all(".qa-provider_row")
      end
    end
  end
end
