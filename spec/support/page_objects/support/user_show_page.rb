# frozen_string_literal: true

module PageObjects
  module Support
    class UserShow < PageObjects::Base
      set_url "/support/users/{id}"

      sections :provider_rows, PageObjects::Sections::Provider, ".qa-provider_row"

      element :delete_button, ".govuk-button"
    end
  end
end
