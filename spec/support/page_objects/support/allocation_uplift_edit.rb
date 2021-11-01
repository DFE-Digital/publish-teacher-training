# frozen_string_literal: true

module PageObjects
  module Support
    class AllocationUpliftEdit < PageObjects::Base
      set_url "/support/allocation_uplifts/{uplift_id}/edit?allocation_id={allocation_id}"

      element :allocation_uplift_amount, "#allocation-uplift-uplifts-field"
      element :submit, ".govuk-button"
    end
  end
end
