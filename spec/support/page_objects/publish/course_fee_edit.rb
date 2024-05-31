# frozen_string_literal: true

require_relative '../sections/error_link'
require_relative '../sections/copy_content'

module PageObjects
  module Publish
    class CourseFeeEdit < PageObjects::Base
      set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/fees'

      sections :errors, Sections::ErrorLink, '.govuk-error-summary__list li>a'

      element :copy_content_warning, '[data-qa="copy-course-warning"]'
      element :uk_fee, '#publish-course-fee-form-fee-uk-eu-field'
      element :international_fee, '#publish-course-fee-form-fee-international-field'

      section :copy_content, Sections::CopyContent

      element :submit, 'button.govuk-button[type="submit"]'

      def error_messages
        errors.map(&:text)
      end
    end
  end
end
