# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class SkilledWorkerVisaSponsorship < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/skilled-worker-visa-sponsorship/new{?query*}"

        element :continue, '[data-qa="course__save"]'

        element :yes, "#course_can_sponsor_skilled_worker_visa_true"
      end
    end
  end
end
