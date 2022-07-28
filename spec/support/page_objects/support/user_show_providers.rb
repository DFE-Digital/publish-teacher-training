# frozen_string_literal: true

module PageObjects
  module Support
    class UserShowProviders < PageObjects::Base
      set_url "/support/{recruitment_cycle_year}/users/{id}/providers"

      sections :provider_rows, PageObjects::Sections::Provider, ".qa-provider_row"

      element :remove_user_from_provider_button, "#remove-provider"
    end
  end
end
