# frozen_string_literal: true

module PageObjects
  module Publish
    class SignIn < PageObjects::Base
      set_url "/sign-in"

      element :page_heading, ".govuk-heading-l"

      element :email_field, "#user-email-field"

      element :sign_in_button, ".qa-sign_in_button"
    end
  end
end
