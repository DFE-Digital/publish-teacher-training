# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderIndex < PageObjects::Base
      set_url "/support/providers"

      def providers
        page.find_all(".qa-provider_row")
      end
    end
  end
end
