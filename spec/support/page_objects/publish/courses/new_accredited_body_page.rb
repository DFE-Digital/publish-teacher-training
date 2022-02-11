# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewAccreditedBody < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/accredited-body/new{?query*}"

        elements :suggested_accredited_bodies, '[data-qa="course__accredited_body_option"]'

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
