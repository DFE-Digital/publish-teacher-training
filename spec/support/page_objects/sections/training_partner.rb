# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class TrainingPartner < PageObjects::Sections::Base
      element :name, '[data-qa="training_partner_name"]'
      element :course_count, '[data-qa="course_count"]'
    end
  end
end
