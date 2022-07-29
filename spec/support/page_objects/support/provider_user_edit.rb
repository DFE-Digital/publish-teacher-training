# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderUserEdit < PageObjects::Base
      set_url "/support/{recruitment_cycle_year}/providers/{provider_id}/users/{id}/edit"

      element :first_name, "#support-user-form-first-name-field"
      element :last_name, "#support-user-form-last-name-field"
      element :email, "#support-user-form-email-field"

      element :update_user, 'button.govuk-button[type="submit"]'
    end
  end
end
