# frozen_string_literal: true

require_relative '../../sections/error_link'
require_relative '../../sections/radio_button'

module PageObjects
  module Publish
    module Courses
      class OutcomeEdit < PageObjects::Base
        set_url '/publish/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/outcome'

        sections :errors, Sections::ErrorLink, '.govuk-error-summary__list li>a'

        sections :qualifications, Sections::RadioButton, '.govuk-radios__item'

        element :qts, '#course_qualification_qts'
        element :pgce_with_qts, '#course_qualification_pgce_with_qts'

        element :submit, 'input.govuk-button[type="submit"]'

        def error_messages
          errors.map(&:text)
        end

        def qualification_names
          qualifications.map { |el| el.find('.govuk-label').text }
        end
      end
    end
  end
end
