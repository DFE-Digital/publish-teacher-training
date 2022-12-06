# frozen_string_literal: true

module PageObjects
  module Publish
    class UsersNew < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/users/new"

      element :first_name, "#publish-user-form-first-name-field"
      element :last_name, "#publish-user-form-last-name-field"
      element :last_name, "#publish-user-form-last-name-field"
      element :email, "#publish-user-form-email-field"

      element :error_summary, ".govuk-error-summary"

      element :continue, 'button.govuk-button[type="submit"]'
    end
  end
end
