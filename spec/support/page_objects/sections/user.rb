# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class User < PageObjects::Sections::Base
      element :full_name, ".govuk-link"
    end
  end
end
