# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      module User
        class UsersNew < PageObjects::Base
          set_url "/support/providers/{provider_id}/users/new"

          element :first_name, "#support-user-form-first-name-field"
          element :last_name, "#support-user-form-last-name-field"
          element :email, "#support-user-form-email-field"

          element :error_summary, ".govuk-error-summary"

          element :submit, 'button.govuk-button[type="submit"]'
        end
      end
    end
  end
end


