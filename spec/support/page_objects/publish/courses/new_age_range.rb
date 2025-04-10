# frozen_string_literal: true

module PageObjects
  module Publish
    module Courses
      class NewAgeRange < PageObjects::Base
        set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/age-range/new{?query*}"

        section :age_range_fields, '[data-qa="course__age_range_in_years"]' do
          element :three_to_eleven, '[data-qa="course__age_range_in_years_3_to_7_radio"]'
          element :five_to_eleven, '[data-qa="course__age_range_in_years_5_to_11_radio"]'
          element :seven_to_eleven, '[data-qa="course__age_range_in_years_7_to_11_radio"]'
          element :seven_to_fourteen, '[data-qa="course__age_range_in_years_7_to_14_radio"]'
        end

        element :age_range_other, '[data-qa="course__age_range_in_years_other_radio"]'
        element :age_range_from_field, '[data-qa="course__age_range_in_years_other_from_input"]'
        element :age_range_to_field, '[data-qa="course__age_range_in_years_other_to_input"]'

        element :continue, '[data-qa="course__save"]'
      end
    end
  end
end
