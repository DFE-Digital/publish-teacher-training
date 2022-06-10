# frozen_string_literal: true

module PageObjects
  module Publish
    class Rollover < PageObjects::Base
      set_url "/publish/rollover"

      element :submit, 'button.govuk-button[type="submit"]'
    end
  end
end
