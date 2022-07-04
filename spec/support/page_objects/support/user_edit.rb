# frozen_string_literal: true

module PageObjects
  module Support
    class UserEdit < PageObjects::Base
      set_url "/support/users/{id}/edit"

      element :first_name_field, "#user-first-name-field"
      element :last_name_field, "#user-last-name-field"
      element :email_field, "#user-email-field"
      element :admin_checkbox, "#user-admin-true-field"

      element :update, ".govuk-button", text: "Update"
    end
  end
end
