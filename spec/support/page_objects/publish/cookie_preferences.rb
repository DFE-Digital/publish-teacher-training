# frozen_string_literal: true

require_relative "../sections/error_link"

module PageObjects
  module Publish
    class CookiePreferences < PageObjects::Base
      set_url "/cookies"

      element :heading, "h1"

      element :yes_option, "#publish-cookie-preferences-form-analytics-consent-granted-field"
      element :no_option, "#publish-cookie-preferences-form-analytics-consent-denied-field"

      element :submit, 'button.govuk-button[type="submit"]'

      sections :errors, PageObjects::Sections::ErrorLink, ".govuk-error-summary__list li>a"

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
