# frozen_string_literal: true

module PageObjects
  module PublishInterface
    module Courses
      class NewSubjects < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/subjects/new"

        element :title, '[data-qa="page-heading"]'
        element :subjects_fields, '[data-qa="course__subjects"]'
        element :master_subject_fields, '[data-qa="course__master_subject"]'
        element :subordinate_subject_details, '[data-qa="course__subordinate_subject_details"]'
        element :subordinate_subjects_fields, '[data-qa="course__subordinate_subjects"]'
        element :continue, '[data-qa="course__save"]'
        element :google_form_link, '[data-qa="course__google_form_link"]'

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
