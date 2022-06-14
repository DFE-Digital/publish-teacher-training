# frozen_string_literal: true

require_relative "../../sections/errorlink"

module PageObjects
  module Publish
    module Courses
      class Withdrawal < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/withdraw"

        sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

        element :confirm_course_code, "#publish-course-withdrawal-form-confirm-course-code-field"

        element :submit, 'button.govuk-button[type="submit"]'

        def error_messages
          errors.map(&:text)
        end
      end
    end
  end
end
