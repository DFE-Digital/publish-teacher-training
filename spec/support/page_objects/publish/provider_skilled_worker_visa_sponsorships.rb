# frozen_string_literal: true

module PageObjects
  module Publish
    class ProviderSkilledWorkerVisaSponsorships < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/skilled-worker-visa"

      element :can_sponsor_skilled_worker_visa, "#publish-provider-skilled-worker-visa-form-can-sponsor-skilled-worker-visa-true-field"
      element :cant_sponsor_skilled_worker_visa, "#publish-provider-skilled-worker-visa-form-can-sponsor-skilled-worker-visa-field"

      element :update_skilled_worker_visas, ".govuk-button", text: "Update Skilled Worker visas"
    end
  end
end
