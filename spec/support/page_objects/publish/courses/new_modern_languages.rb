# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewModernLanguages < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/modern-languages/new{?query*}"

        element :languages_fields, '[data-qa="course__languages"]'
        element :page_heading, '[data-qa="page-heading"]'

        element :continue, '[data-qa="course__save"]'

        def language_checkbox(name)
          languages_fields.find("[data-qa=\"checkbox_language_#{name}\"]")
        end

        def has_no_language_checkbox?(name)
          languages_fields.has_css?("[data-qa=\"checkbox_language_#{name}\"]")
        end
      end
    end
  end
end
