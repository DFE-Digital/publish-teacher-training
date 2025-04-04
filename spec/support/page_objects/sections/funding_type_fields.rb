# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class FundingTypeFields < PageObjects::Sections::Base
      element :apprenticeship, '[data-qa="course__funding_type_apprenticeship"]'
      element :fee, '[data-qa="course__funding_type_fee"]'
      element :salary, '[data-qa="course__funding_type_salary"]'
    end
  end
end
