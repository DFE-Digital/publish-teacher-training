# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class UserShow < PageObjects::Base
        set_url "/support/providers/{provider_id}/users/{id}"

        element :first_name, "#first_name"
        element :last_name, "#last_name"
        element :email, "#email"
        element :organisations, "#organisations"
        element :date_last_signed_in, "#date_last_signed_in"

        element :delete_button, ".govuk-button", text: "Delete this user"
      end
    end
  end
end
