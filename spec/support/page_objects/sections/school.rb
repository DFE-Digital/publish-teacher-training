# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class School < PageObjects::Sections::Base
      element :name, ".name"
      element :code, ".code"
      element :urn, ".urn"
      element :address, ".address"
      element :courses_count, ".courses-count"
      element :remove_link, ".remove a"
      element :edit_link, ".name a"
    end
  end
end
