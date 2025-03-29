# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewVisaSponsorshipApplicationDeadlineDate < PageObjects::Base
        set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/visa-sponsorship-application-deadline-date/new{?query*}'

        element :day, '#course_visa_sponsorship_application_deadline_at_3i'
        element :month, '#course_visa_sponsorship_application_deadline_at_2i'
        element :year, '#course_visa_sponsorship_application_deadline_at_1i'

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
