# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class CopyContent < PageObjects::Sections::Base
      set_default_search_arguments '[data-qa="course__copy-content-form"]'

      def copy_options
        find('select#copy-from').all('option').collect(&:text)
      end

      def copy(course)
        select("#{course.name} (#{course.course_code})", from: "Copy from")
        click_on("Copy content")
      end
    end
  end
end
