# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class Course < PageObjects::Sections::Base
      element :name, ".name"
      element :change_link, ".change a.govuk-link"
    end
  end
end
