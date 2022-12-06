# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class ErrorLink < PageObjects::Sections::Base
      element :link, "a"
    end
  end
end
