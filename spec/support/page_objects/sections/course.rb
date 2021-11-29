# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class Course < PageObjects::Sections::Base
      element :name, ".name"
      element :course_code, ".course_code"
      element :edit_link, ".course_code a.govuk-link"
    end
  end
end
