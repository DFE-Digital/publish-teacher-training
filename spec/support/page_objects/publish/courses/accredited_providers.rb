# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class AccreditedProviders < PageObjects::Base
        set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/accredited-provider'

        elements :suggested_accredited_bodies, '[data-qa="course__accredited_provider_option"]'
        element :add_new_button, '.govuk-button--secondary'

        element :update_button, 'input[type=submit]'
      end
    end
  end
end
