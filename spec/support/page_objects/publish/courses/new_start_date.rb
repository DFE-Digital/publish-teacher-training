# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewStartDate < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/start-date/new{?query*}"

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
