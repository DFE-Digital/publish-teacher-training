# frozen_string_literal: true

require_relative "base"
require "forwardable"

module PageObjects
  module Sections
    class Vacancy < PageObjects::Sections::Base
      extend Forwardable

      element :name, ".govuk-checkboxes__label"
      element :checkbox, ".govuk-checkboxes__input"

      def_delegators :checkbox, :checked?
    end
  end
end
