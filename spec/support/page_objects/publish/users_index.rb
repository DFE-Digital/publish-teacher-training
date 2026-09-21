# frozen_string_literal: true

require_relative "../sections/user"

module PageObjects
  module Publish
    class UsersIndex < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/users"

      sections :users, PageObjects::Sections::User, ".user-row"
      element :add_user, ".govuk-button", text: "Add user"
    end
  end
end
