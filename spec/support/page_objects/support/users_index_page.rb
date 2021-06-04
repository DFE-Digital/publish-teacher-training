# frozen_string_literal: true

module PageObjects
  module Support
    class UsersIndex < PageObjects::Base
      set_url "/support/users"

      element :add_a_user, "a", text: "Add a user"

      def users
        page.find_all(".user-row")
      end
    end
  end
end
