# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderNew < PageObjects::Base
      set_url "/support/providers/new"

      element :provider_name, "#provider-provider-name-field"
      element :provider_code, "#provider-provider-code-field"
      element :provider_type_scitt, "#provider-provider-type-scitt-field"
      element :provider_email, "#provider-email-field"
      element :provider_telephone, "#provider-telephone-field"
      element :site_name, "#provider-sites-attributes-0-name-field"
      element :site_code, "#provider-sites-attributes-0-code-field"
      element :site_location_name, "#provider-sites-attributes-0-location-name-field"
      element :site_address1, "#provider-sites-attributes-0-address1-field"
      element :site_address2, "#provider-sites-attributes-0-address2-field"
      element :site_address3, "#provider-sites-attributes-0-address3-field"
      element :site_address4, "#provider-sites-attributes-0-address4-field"
      element :site_postcode, "#provider-sites-attributes-0-postcode-field"
      element :error_summary, ".govuk-error-summary"
      element :submit, ".govuk-button"
    end
  end
end
