# frozen_string_literal: true

module PageObjects
  module Publish
    class UsersDelete < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/users/{user_id}/delete"

      element :remove_user_button, ".govuk-button", text: "Remove user"
    end
  end
end
