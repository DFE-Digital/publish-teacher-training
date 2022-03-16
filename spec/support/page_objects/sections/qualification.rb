# frozen_string_literal: true

require_relative "base"
require "forwardable"

module PageObjects
  module Sections
    class Qualification < PageObjects::Sections::Base
      extend Forwardable

      element :name, ".govuk-radios__label"
      element :radio, ".govuk-radios__input"

      def_delegators :radio, :checked?
    end
  end
end
