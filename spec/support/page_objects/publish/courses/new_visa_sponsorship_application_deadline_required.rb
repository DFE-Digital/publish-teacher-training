# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewVisaSponsorshipApplicationDeadlineRequired < PageObjects::Base
        set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/visa-sponsorship-application-deadline-required/new{?query*}'

        element :yes, '#course-visa-sponsorship-application-deadline-required-true-field'
        element :no, '#course-visa-sponsorship-application-deadline-required-false-field'

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
