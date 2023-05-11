# frozen_string_literal: true

require_relative '../sections/error_link'

module PageObjects
  module Find
    class CookiePreferences < PageObjects::Base
      set_url '/cookies'

      element :heading, 'h1'

      element :analytics_cookie_accept, '#find-cookie-preferences-form-analytics-consent-granted-field'
      element :analytics_cookie_deny, '#find-cookie-preferences-form-analytics-consent-denied-field'

      element :submit, 'button.govuk-button[type="submit"]'

      sections :errors, PageObjects::Sections::ErrorLink, '.govuk-error-summary__list li>a'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
