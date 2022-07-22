# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderUserShow < PageObjects::Base
      set_url "/support/providers/{provider_id}/users/{id}"

      element :first_name, "#first_name"
      element :last_name, "#last_name"
      element :email, "#email"
      element :organisations, "#organisations"
      element :date_last_signed_in, "#date_last_signed_in"

      element :remove_user_link, ".govuk-link", text: "Remove user"

      element :change_first_name, "a.govuk-link.first_name", text: "Change"
      element :change_last_name, "a.govuk-link.last_name", text: "Change"
      element :change_email, "a.govuk-link.email", text: "Change"
    end
  end
end
