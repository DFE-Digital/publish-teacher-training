# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewFeeOrSalary < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/fee-or-salary/new{?query*}"

        section :funding_type_fields, Sections::FundingTypeFields, '[data-qa="course__funding_type"]'

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
