# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class Location < PageObjects::Sections::Base
      element :name, ".name"
      element :code, ".code"
      element :urn, ".urn"
      element :edit_link, ".name a"
    end
  end
end
