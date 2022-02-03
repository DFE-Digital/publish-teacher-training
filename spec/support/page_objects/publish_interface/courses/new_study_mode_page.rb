# frozen_string_literal: true

module PageObjects
  module PublishInterface
    module Courses
      class NewStudyMode < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/full-part-time/new{?query*}"

        section :study_mode_fields, '[data-qa="course__study_mode"]' do
          element :full_time, "#course_study_mode_full_time"
          element :part_time, "#course_study_mode_part_time"
          element :full_time_or_part_time, "#course_study_mode_full_time_or_part_time"
        end

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
