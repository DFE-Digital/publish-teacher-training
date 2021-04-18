# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderEdit < PageObjects::Base
      set_url "/support/providers/{id}/edit"

      element :provider_name, "#provider-provider-name-field"
      element :error_summary, ".govuk-error-summary"
      element :submit, ".govuk-button"
    end
  end
end
