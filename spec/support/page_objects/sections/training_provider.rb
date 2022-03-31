# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class TrainingProvider < PageObjects::Sections::Base
      element :name, '[data-qa="link"]'
      element :course_count, '[data-qa="course_count"]'
    end
  end
end
