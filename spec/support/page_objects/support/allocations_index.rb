# frozen_string_literal: true

module PageObjects
  module Support
    class AllocationsIndex < PageObjects::Base
      set_url "/support/allocations"

      def providers
        page.find_all(".qa-provider_row")
      end
    end
  end
end
