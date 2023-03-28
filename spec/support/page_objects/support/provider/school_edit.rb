# frozen_string_literal: true

module PageObjects
  module Support
    module Provider
      class SchoolEdit < PageObjects::Base
        set_url '/support/{recruitment_cycle_year}/providers/{provider_id}/schools/{school_id}/edit'
        element :error_summary, '.govuk-error-summary'

        section :school_form, Sections::SchoolForm, '.school-form'

        element :submit, 'button.govuk-button[type="submit"]', text: 'Update'
        element :delete_record, 'button.govuk-button[type="submit"]', text: 'Delete this school'

        def errors
          within(error_summary) do
            all('.govuk-error-summary__list li').map(&:text)
          end
        end
      end
    end
  end
end
