# frozen_string_literal: true

module PageObjects
  module Support
    class AllocationUpliftNew < PageObjects::Base
      set_url "/support/allocations/{allocation_id}/uplifts/new"

      element :allocation_uplift_amount, "#allocation-uplift-uplifts-field"
      element :submit, ".govuk-button", text: "Update"
    end
  end
end
