# frozen_string_literal: true

module PageObjects
  module PublishInterface
    class ProviderUsers < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/users"

      element :request_access, "#govuk-button"
      element :heading, "h1"
      element :user_name, "h2", match: :first
    end
  end
end
