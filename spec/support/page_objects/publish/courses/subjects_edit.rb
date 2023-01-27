# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class SubjectsEdit < PageObjects::Base
        set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/subjects'

        element :title, '[data-qa="page-heading"]'
        element :master_subject_fields, '[data-qa="course__master_subject"]'
        element :subordinate_subjects_fields, '[data-qa="course__subordinate_subjects"]'
        element :google_form_link, '[data-qa="course__google_form_link"]'

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
