# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class StatusSidebar < PageObjects::Sections::Base
      element :unpublished_partial, '[data-qa="unpublished__partial"]'
      element :published_partial, '[data-qa="published__partial"]'

      element :delete_course_link, "a.govuk-link.app-link--destructive", text: "Delete this course"
      element :publish_button, '[data-qa="course__publish"]'
    end
  end
end
