# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class RatifyingProviders < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/ratifying-provider"

        elements :suggested_accredited_partners, '[data-qa="course__accredited_provider_option"]'
        element :add_new_link, '[data-qa="course__add"]'

        element :update_button, "input[type=submit]"
      end
    end
  end
end
