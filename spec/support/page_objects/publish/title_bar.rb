# frozen_string_literal: true

module PageObjects
  module Publish
    class TitleBar < PageObjects::Base
      element :recruitment_cycle_text, ".govuk-hint"
    end
  end
end
