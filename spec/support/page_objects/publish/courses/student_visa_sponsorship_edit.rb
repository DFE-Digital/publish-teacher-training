# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class StudentVisaSponsorshipEdit < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/student-visa-sponsorship"

        element :yes, "#publish-course-funding-form-can-sponsor-student-visa-true-field"

        element :update, 'button.govuk-button[type="submit"]'
      end
    end
  end
end
