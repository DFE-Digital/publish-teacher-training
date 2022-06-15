# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewFeeOrSalary < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/fee-or-salary/new{?query*}"

        section :funding_type_fields, '[data-qa="course__funding_type"]' do
          element :apprenticeship, '[data-qa="course__funding_type_apprenticeship"]'
          element :fee, '[data-qa="course__funding_type_fee"]'
          element :salary, '[data-qa="course__funding_type_salary"]'
        end

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
