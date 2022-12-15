# frozen_string_literal: true

module PageObjects
  module Publish
    class UsersEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/users/edit"

      element :first_name, "#publish-user-form-first-name-field"
      element :last_name, "#publish-user-form-last-name-field"
      element :last_name, "#publish-user-form-last-name-field"
      element :email, "#publish-user-form-email-field"
    end
  end
end
