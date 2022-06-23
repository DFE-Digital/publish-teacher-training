# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class CookiePreferences < PageObjects::Base
      set_url "/cookies"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :yes_option, "#publish-cookie-preferences-form-consent-yes-field"
      element :no_option, "#publish-cookie-preferences-form-consent-no-field"

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
