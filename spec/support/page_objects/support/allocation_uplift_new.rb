# frozen_string_literal: true

module PageObjects
  module Support
    class AllocationUpliftNew < PageObjects::Base
      set_url "/support/allocation_uplifts/new?allocation_id={allocation_id}"

      element :allocation_uplift_amount, "#allocation-uplift-uplifts-field"
      element :submit, ".govuk-button"
    end
  end
end
