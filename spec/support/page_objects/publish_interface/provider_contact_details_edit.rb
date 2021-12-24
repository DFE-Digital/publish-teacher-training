module PageObjects
  module PublishInterface
    class ProviderContactDetailsEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/contact/edit"

      element :error_summary, ".govuk-error-summary"
      element :email, "#publish-interface-provider-contact-form-email-field"
      element :telephone, "#publish-interface-provider-contact-form-telephone-field"
      element :ukprn, "#publish-interface-provider-contact-form-ukprn-field"
      element :urn, "#publish-interface-provider-contact-form-urn-field"
      element :address1, "#publish-interface-provider-contact-form-address1-field"

      element :save_and_publish, ".govuk-button"

      def errors
        within(error_summary) do
          all(".govuk-error-summary__list li").map(&:text)
        end
      end
    end
  end
end
