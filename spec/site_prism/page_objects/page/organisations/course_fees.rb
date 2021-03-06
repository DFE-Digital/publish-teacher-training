module PageObjects
  module Page
    module Organisations
      class CourseFees < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/fees"

        element :enrichment_form, '[data-qa="enrichment-form"]'
        element :course_length_one_year, '[data-qa="course_course_length_oneyear"]'
        element :course_length_two_years, '[data-qa="course_course_length_twoyears"]'
        element :course_length_other, '[data-qa="course_course_length_other"]'
        element :course_length_other_length, '[data-qa="course_course_length_other_length"]'
        element :course_fees_uk_eu, '[data-qa="course_fee_uk_eu"]'
        element :course_fees_international, '[data-qa="course_fee_international"]'
        element :fee_details, '[data-qa="course_fee_details"]'
        element :financial_support, '[data-qa="course_financial_support"]'
      end
    end
  end
end
