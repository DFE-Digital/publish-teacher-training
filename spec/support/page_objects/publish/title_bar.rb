# frozen_string_literal: true

module PageObjects
  module Publish
    class TitleBar < PageObjects::Base
      element :recruitment_cycle_text, ".govuk-hint", text: "- 2021 to 2022 - current"
    end
  end
end
