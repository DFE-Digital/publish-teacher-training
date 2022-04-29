# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class Notification < PageObjects::Base
      set_url "/publish/notifications"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      element :opt_in_radio, "#publish-notification-form-explicitly-enabled-true-field"
      element :opt_out_radio, "#publish-notification-form-explicitly-enabled-field"

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
