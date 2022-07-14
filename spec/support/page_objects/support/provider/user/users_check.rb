# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      module User
        class UsersCheck < PageObjects::Base
          set_url "/support/providers/{provider_id}/users/check"

          element :add_user, ".govuk-button", text: "Add user"
        end
      end
    end
  end
end
