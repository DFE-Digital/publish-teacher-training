# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewLocations < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/locations/new{?query*}"

        element :title, '[data-qa="page-heading"]'

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
