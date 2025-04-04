# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class Details < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/details"

        section :details, '[id="basic_details"]' do
          element :ratifying_provider_row, '[data-qa="course__ratifying_provider"]'
        end
      end
    end
  end
end
