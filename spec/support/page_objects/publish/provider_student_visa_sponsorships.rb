# frozen_string_literal: true

module PageObjects
  module Publish
    class ProviderStudentVisaSponsorships < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/student-visa"

      element :can_sponsor_student_visa, "#publish-provider-student-visa-form-can-sponsor-student-visa-true-field"
      element :cant_sponsor_student_visa, "#publish-provider-student-visa-form-can-sponsor-student-visa-field"

      element :update_student_visas, ".govuk-button", text: "Update Student visas"
    end
  end
end
