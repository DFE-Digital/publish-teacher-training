# frozen_string_literal: true

module PageObjects
  module Support
    class UserNew < PageObjects::Base
      set_url "/support/{recruitment_cycle_year}/users/wizard/{state_key}/details"

      element :first_name, "#details-first-name-field"
      element :last_name, "#details-last-name-field"
      element :email, "#details-email-field"

      element :error_summary, ".govuk-error-summary"

      element :submit, 'button.govuk-button[type="submit"]'
    end
  end
end
