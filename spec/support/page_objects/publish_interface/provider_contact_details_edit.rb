module PageObjects
  module PublishInterface
    class ProviderContactDetailsEdit < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/contact"

      element :error_summary, ".govuk-error-summary"
      element :email, "#publish-interface-about-your-organisation-form-email-field"
      element :telephone, "#publish-interface-about-your-organisation-form-telephone-field"
      element :address1, "#publish-interface-about-your-organisation-form-address1-field"

      element :save_and_publish, ".govuk-button"
    end
  end
end
