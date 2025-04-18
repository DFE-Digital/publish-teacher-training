# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewSubjects < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/subjects/new{?query*}"

        element :page_heading, '[data-qa="page-heading"]'
        element :master_subject_fields, '[data-qa="course__master_subject"]'
        element :subordinate_subjects_fields, '[data-qa="course__subordinate_subjects"]'
        element :google_form_link, '[data-qa="course__google_form_link"]'

        element :back, '[data-qa="page-back"]'
        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
