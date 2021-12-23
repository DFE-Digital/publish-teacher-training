# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class Location < PageObjects::Sections::Base
      element :name, ".name"
      element :code, ".code"
      element :urn, ".urn"
    end
  end
end
