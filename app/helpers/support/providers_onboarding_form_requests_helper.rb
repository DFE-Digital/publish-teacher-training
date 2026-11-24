# frozen_string_literal: true

module Support
  module ProvidersOnboardingFormRequestsHelper
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
  end
end
