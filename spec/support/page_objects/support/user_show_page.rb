# frozen_string_literal: true

module PageObjects
  module Support
    class UserShow < PageObjects::Base
      set_url "/support/users/{id}"

      element :delete_button, ".govuk-button"
    end
  end
end
