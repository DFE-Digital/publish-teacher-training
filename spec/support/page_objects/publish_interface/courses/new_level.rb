# frozen_string_literal: true

module PageObjects
  module PublishInterface
    module Courses
      class NewLevel < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/level/new"

        section :level_fields, '[data-qa="course__level"]' do
          element :primary,           "#course_level_primary"
          element :secondary,         "#course_level_secondary"
          element :further_education, "#course_level_further_education"
        end

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
