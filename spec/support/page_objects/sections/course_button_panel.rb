# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class CourseButtonPanel < PageObjects::Sections::Base
      element :publish_button, '[data-qa="course__publish"]'
      element :delete_link, '[data-qa="course__delete-link"]'

      element :view_on_find, '[data-qa="course__is_findable"]'
      element :withdraw_link, '[data-qa="course__withdraw-link"]'
      element :vacancies_link, '[data-qa="course__has_vacancies"]'
    end
  end
end
