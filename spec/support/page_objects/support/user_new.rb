# frozen_string_literal: true

module PageObjects
  module Support
    class UserNew < PageObjects::Base
      set_url "/support/{recruitment_cycle_year}/users/new"

      element :first_name, "#user-first-name-field"
      element :last_name, "#user-last-name-field"
      element :email, "#user-email-field"

      element :error_summary, ".govuk-error-summary"

      element :submit, 'button.govuk-button[type="submit"]'
    end
  end
end
