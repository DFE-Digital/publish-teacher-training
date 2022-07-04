# frozen_string_literal: true

module PageObjects
  module Support
    class AllocationUpliftEdit < PageObjects::Base
      set_url "/support/allocations/{allocation_id}/uplifts/{uplift_id}/edit"

      element :allocation_uplift_amount, "#allocation-uplift-uplifts-field"
      element :submit, ".govuk-button", text: "Continue"
    end
  end
end
