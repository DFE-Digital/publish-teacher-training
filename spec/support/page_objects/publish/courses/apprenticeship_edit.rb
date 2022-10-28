# frozen_string_literal: true

require_relative "../../sections/funding_type_fields"

module PageObjects
  module Publish
    module Courses
      class ApprenticeshipEdit < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/apprenticeship"

        section :funding_type_fields, '[data-qa="course__funding_type"]' do
          element :yes, "#publish_course_funding_form_funding_type_apprenticeship"
          element :no, "#publish_course_funding_form_funding_type_fee"
        end

        element :update, '[data-qa="course__save"]'
      end
    end
  end
end
