# frozen_string_literal: true

module PageObjects
  module Publish
    class UsersShow < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/users/{id}"

      element :remove_user_link, ".govuk-link", text: "Remove user"
    end
  end
end
