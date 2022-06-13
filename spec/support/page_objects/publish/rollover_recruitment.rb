# frozen_string_literal: true

module PageObjects
  module Publish
    class RolloverRecruitment < PageObjects::Base
      set_url "/publish/rollover-recruitment"

      element :submit, 'button.govuk-button[type="submit"]'
    end
  end
end
