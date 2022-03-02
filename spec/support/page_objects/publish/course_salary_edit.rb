# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class CourseSalaryEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/salary"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      section :course_length, "#course-length" do
        element :one_year, "#publish-course-salary-form-course-length-oneyear-field"
        element :upto_two_years, "#publish-course-salary-form-course-length-twoyears-field"
        element :other, "#publish-course-salary-form-course-length-other-field"
        element :other_text, "#publish-course-salary-form-course-length-other-length-field"
      end

      element :salary_details, "#publish-course-salary-form-salary-details-field"

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
