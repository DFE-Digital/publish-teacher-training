# frozen_string_literal: true

require_relative "../../sections/copy_content"

require_relative "../../sections/errorlink"

module PageObjects
  module Publish
    module Courses
      class GcseRequirementsPage < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/gcses-pending-or-equivalency-tests{?query*}"

        element :copy_content_warning, '[data-qa="copy-course-warning"]'
        
        sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li"

        element :pending_gcse_yes_radio, '[data-qa="gcse_requirements__pending_gcse_yes_radio"]'
        element :pending_gcse_no_radio, '[data-qa="gcse_requirements__pending_gcse_no_radio"]'

        element :gcse_equivalency_yes_radio, '[data-qa="gcse_requirements__gcse_equivalency_yes_radio"]'
        element :english_equivalency, '[data-qa="gcse_requirements__english_equivalency"]'
        element :maths_equivalency, '[data-qa="gcse_requirements__maths_equivalency"]'
        element :science_equivalency, '[data-qa="gcse_requirements__science_equivalency"]'
        element :additional_requirements, '[data-qa="gcse_requirements__additional_requirements"]'
        element :gcse_equivalency_no_radio, '[data-qa="gcse_requirements__gcse_equivalency_no_radio"]'
        element :use_content, '[data-qa="course__use_content"]'

        section :copy_content, Sections::CopyContent

        element :save, '[data-qa="gcse_requirements__save"]'

        def error_messages
          errors.map(&:text)
        end
      end
    end
  end
end
