# frozen_string_literal: true

module PageObjects
  module Publish
    class ProviderVisaSponsorships < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/visas"

      element :can_sponsor_student_visa, "#publish-provider-visa-form-can-sponsor-student-visa-true-field"
      element :cant_sponsor_student_visa, "#publish-provider-visa-form-can-sponsor-student-visa-field"

      element :can_sponsor_skilled_worker_visa, "#publish-provider-visa-form-can-sponsor-skilled-worker-visa-true-field"
      element :cant_sponsor_skilled_worker_visa, "#publish-provider-visa-form-can-sponsor-skilled-worker-visa-field"

      element :save_and_publish, ".govuk-button", text: "Save and publish"
    end
  end
end
