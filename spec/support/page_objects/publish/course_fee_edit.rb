# frozen_string_literal: true

require_relative "../sections/errorlink"

module PageObjects
  module Publish
    class CourseFeeEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/fees"

      sections :errors, Sections::ErrorLink, ".govuk-error-summary__list li>a"

      section :course_length, "#course-length" do
        element :one_year, "#publish-course-fee-form-course-length-oneyear-field"
        element :upto_two_years, "#publish-course-fee-form-course-length-twoyears-field"
        element :other, "#publish-course-fee-form-course-length-other-field"
        element :other_text, "#publish-course-fee-form-course-length-other-length-field"
      end

      element :uk_fee, "#publish-course-fee-form-fee-uk-eu-field"
      element :international_fee, "#publish-course-fee-form-fee-international-field"
      element :fee_details, "#publish-course-fee-form-fee-details-field"
      element :financial_support, "#publish-course-fee-form-financial-support-field"

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
