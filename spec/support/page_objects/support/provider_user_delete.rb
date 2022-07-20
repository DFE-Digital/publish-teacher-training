# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderUserDelete < PageObjects::Base
      set_url "/support/providers/{provider_id}/users/{id}/delete"

      element :heading, "h1"
      element :warning_text, ".govuk-warning-text"
      element :cancel_link, ".govuk-link", text: "Cancel"

      element :remove_user_button, ".govuk-button", text: "Remove user"
    end
  end
end
