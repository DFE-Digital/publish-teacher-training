# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewStudyMode < PageObjects::Base
        set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/full-part-time/new{?query*}'

        section :study_mode_fields, '[data-qa="course__study_mode"]' do
          element :full_time, '#course-study-mode-full-time-field'
          element :part_time, '#course-study-mode-part-time-field'
        end

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
