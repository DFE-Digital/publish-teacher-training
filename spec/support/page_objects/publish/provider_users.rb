# frozen_string_literal: true

module PageObjects
  module Publish
    class ProviderUsers < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/users"

      element :request_access, ".govuk-button", text: "Request access"
      element :heading, "h1"
      element :user_name, '[data-qa="provider_user"]', match: :first
    end
  end
end
