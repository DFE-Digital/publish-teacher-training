# frozen_string_literal: true

module PageObjects
  module Publish
    class UsersShow < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/users/{id}"

      element :remove_user_link, ".govuk-link", text: "Remove user"

      element :change_first_name, "a.govuk-link", text: "Change last name"
      element :change_last_name, "a.govuk-link", text: "Change first name"
      element :change_email_address, "a.govuk-link", text: "Change email address"
    end
  end
end
