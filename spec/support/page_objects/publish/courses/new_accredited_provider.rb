# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewAccreditedProvider < PageObjects::Base
        set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/accredited-provider/new{?query*}'

        elements :suggested_accredited_bodies, '[data-qa="course__accredited_provider_option"]'

        element :continue, '[data-qa="course__save"]'
        element :about_section_input, 'textarea'
        element :submit, 'button[type="submit"]'
      end
    end
  end
end
