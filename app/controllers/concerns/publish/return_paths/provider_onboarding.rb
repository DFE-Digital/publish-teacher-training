# frozen_string_literal: true

module Publish
  module ReturnPaths
    module ProviderOnboarding
    private

      def support_return_path(_state)
        support_providers_onboarding_form_request_path(@onboarding_request)
      end

      def publish_return_path
        check_answers_publish_provider_onboarding_path(uuid: @onboarding_request.uuid)
      end
    end
  end
end
