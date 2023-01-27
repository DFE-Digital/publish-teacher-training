# frozen_string_literal: true

module PageObjects
  module Publish
    class UsersCheck < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/users/check'

      element :add_user, '.govuk-button', text: 'Add user'

      element :change_first_name, 'a.govuk-link.first_name', text: 'Change'
      element :change_last_name, 'a.govuk-link.last_name', text: 'Change'
      element :change_email, 'a.govuk-link.email', text: 'Change'
    end
  end
end
