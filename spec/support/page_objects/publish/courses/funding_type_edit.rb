# frozen_string_literal: true

require_relative "../../sections/funding_type_fields"

module PageObjects
  module Publish
    module Courses
      class FundingTypeEdit < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/funding-type"

        section :funding_type_fields, Sections::FundingTypeFields, '[data-qa="course__funding_type"]'

        element :update, '[data-qa="course__save"]'
      end
    end
  end
end
