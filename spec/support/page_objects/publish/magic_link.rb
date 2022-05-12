# frozen_string_literal: true

module PageObjects
  module Publish
    class MagicLink < PageObjects::Base
      set_url "/sign-in/magic-link"

      element :email_field, "#publish-authentication-magic-link-form-email-field"

      element :submit, 'button.govuk-button[type="submit"]'
    end

    class MagicLinkConfirmation < PageObjects::Base
      set_url "/magic-link-sent"
    end
  end
end
