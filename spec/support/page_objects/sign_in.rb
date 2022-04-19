# frozen_string_literal: true

module PageObjects
  class SignIn < PageObjects::Base
    set_url "/sign-in"

    element :page_heading, ".govuk-heading-l"

    element :sign_in_button, '[data-qa="sign-in-using-a-persona"]'
  end
end
