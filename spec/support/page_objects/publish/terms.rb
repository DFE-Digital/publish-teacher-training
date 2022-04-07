# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class Terms < PageObjects::Base
      set_url "/accept-terms"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :accept_terms, "#publish-accept-terms-form-terms-accepted-1-field"

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
