# frozen_string_literal: true

module PageObjects
  module Publish
    module TrainingProviders
      class CourseIndex < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/training-providers/{training_provider_code}/courses"

        sections :courses, '[data-qa="courses__table-section"]' do
          element :name, '[data-qa="courses-table__course-name"]'
        end
      end
    end
  end
end
