# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderUsersIndex < PageObjects::Base
      set_url "support/providers/{provider_id}/users"

      def users
        page.find_all(".user-row")
      end
    end
  end
end
