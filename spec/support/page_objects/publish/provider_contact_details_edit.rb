# frozen_string_literal: true

module PageObjects
  module Publish
    class ProviderContactDetailsEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/contact"

      element :error_summary, ".govuk-error-summary"
      element :email, "#publish-provider-contact-form-email-field"
      element :telephone, "#publish-provider-contact-form-telephone-field"
      element :ukprn, "#publish-provider-contact-form-ukprn-field"
      element :urn, "#publish-provider-contact-form-urn-field"
      element :address1, "#publish-provider-contact-form-address1-field"

      element :save_and_publish, ".govuk-button", text: "Save and publish"

      def errors
        within(error_summary) do
          all(".govuk-error-summary__list li").map(&:text)
        end
      end
    end
  end
end
