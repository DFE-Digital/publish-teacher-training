# frozen_string_literal: true

module PageObjects
  module Support
    class AllocationsShow < PageObjects::Base
      set_url "/support/allocations/{id}"

      element :change_link, ".govuk-link"
    end
  end
end
