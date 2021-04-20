# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderUsersIndex < PageObjects::Base
      set_url "/support/providers/{provider_id}/users"

      sections :users, PageObjects::Sections::User, ".user-row"
    end
  end
end
