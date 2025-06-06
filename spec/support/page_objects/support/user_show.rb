# frozen_string_literal: true

module PageObjects
  module Support
    class UserShow < PageObjects::Base
      set_url "/support/{recruitment_cycle_year}/users/{id}"

      element :delete_button, ".govuk-button", text: "Delete this user"
      element :first_name, "#first_name"
      element :last_name, "#last_name"
      element :email, "#email"
      element :admin_status, "#admin_status"
    end
  end
end
