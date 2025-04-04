# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class SkilledWorkerVisaSponsorshipEdit < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/skilled-worker-visa-sponsorship"

        element :yes, "#publish-course-funding-form-can-sponsor-skilled-worker-visa-true-field"

        element :update, 'button.govuk-button[type="submit"]'
      end
    end
  end
end
