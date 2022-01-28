# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module PublishInterface
    class RequestAccessNew < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/request-access"

      element :request_access, ".govuk-button"
      element :heading, "h1"

      element :first_name, "#publish-interface-access-request-form-first-name-field"
      element :last_name, "#publish-interface-access-request-form-last-name-field"
      element :email_address, "#publish-interface-access-request-form-email-address-field"
      element :organisation, "#publish-interface-access-request-form-organisation-field"
      element :reason, "#publish-interface-access-request-form-reason-field"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
