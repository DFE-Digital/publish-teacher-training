# frozen_string_literal: true

module Support
  module ProvidersOnboardingFormRequestsHelper
    FIELD_ANCHORS = {
      provider_name: "providers-onboarding-form-request-provider-name-field",
      ukprn: "providers-onboarding-form-request-ukprn-field",
      accredited_provider: "providers-onboarding-form-request-accredited-provider-field-error",
      accredited_provider_number: "providers-onboarding-form-request-accredited-provider-number-field-error",
      provider_type: "providers-onboarding-form-request-provider-type-field",
      urn: "providers-onboarding-form-request-urn-field",
      contact_email_address: "providers-onboarding-form-request-contact-email-address-field",
      telephone: "providers-onboarding-form-request-telephone-field",
      website: "providers-onboarding-form-request-website-field",
      address_line_1: "providers-onboarding-form-request-address-line-1-field",
      email_address: "providers-onboarding-form-request-email-address-field",
      first_name: "providers-onboarding-form-request-first-name-field",
      last_name: "providers-onboarding-form-request-last-name-field",
    }.freeze

    def onboarding_error_summary_item(onboarding_request, error)
      anchor = FIELD_ANCHORS[error.attribute]
      return error.message if anchor.blank?

      link_to(error.message, onboarding_error_path(onboarding_request, error, anchor))
    end

    def accredited_provider_number_change_path(onboarding_request)
      support_onboarding_change_path(onboarding_request, "providers-onboarding-form-request-accredited-provider-number-field")
    end

    def support_onboarding_change_path(onboarding_request, anchor)
      publish_provider_onboarding_path(
        onboarding_request.uuid,
        return_to: Publish::ProviderOnboardingController::SUPPORT_RETURN_TO,
        anchor:,
      )
    end

  private

    def onboarding_error_path(onboarding_request, error, anchor)
      options = { return_to: Publish::ProviderOnboardingController::SUPPORT_RETURN_TO }
      options[:display_errors] = error.attribute if error.attribute == :accredited_provider_number
      options[:anchor] = anchor

      publish_provider_onboarding_path(onboarding_request.uuid, options)
    end
  end
end
