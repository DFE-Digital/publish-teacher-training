# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderUsersIndex < PageObjects::Base
      set_url "/support/providers/{provider_id}/users"

      sections :users, PageObjects::Sections::User, ".user-row"
      element :success_notification, ".govuk-notification-banner.govuk-notification-banner--success"
      element :remove_user_from_provider_button, "#remove-provider"
    end
  end
end
