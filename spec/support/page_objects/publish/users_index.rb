# frozen_string_literal: true

module PageObjects
  module Publish
    class UsersIndex < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/users'

      element :add_user, '.govuk-button', text: 'Add user'
    end
  end
end
