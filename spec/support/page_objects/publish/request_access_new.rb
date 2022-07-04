# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class RequestAccessNew < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/request-access"

      element :request_access, ".govuk-button", text: "Request access"
      element :heading, "h1"

      element :first_name, "#publish-access-request-form-first-name-field"
      element :last_name, "#publish-access-request-form-last-name-field"
      element :email_address, "#publish-access-request-form-email-address-field"
      element :organisation, "#publish-access-request-form-organisation-field"
      element :reason, "#publish-access-request-form-reason-field"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
