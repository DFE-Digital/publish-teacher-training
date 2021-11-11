# frozen_string_literal: true

module PageObjects
  module Support
    class AllocationEdit < PageObjects::Base
      set_url "/support/allocations/{id}/edit"

      element :confirmed_number_of_places, "#allocation-confirmed-number-of-places-field"
      element :submit, ".govuk-button"
    end
  end
end
