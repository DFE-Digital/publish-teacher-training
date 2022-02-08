module PageObjects
  module Sections
    class SummaryList < PageObjects::Sections::Base
      element :key, ".govuk-summary-list__key"
      element :value, ".govuk-summary-list__value"
      element :actions, ".govuk-summary-list__actions"
    end
  end
end
