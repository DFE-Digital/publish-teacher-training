# frozen_string_literal: true

module Publish
  module Providers
    module AccreditedProviders
      class ChecksController < ApplicationController
        def show
          accredited_provider_form
        end

        def update
          accredited_provider_form.save!
          redirect_to publish_provider_recruitment_cycle_accredited_providers_path(@provider.provider_code, @provider.recruitment_cycle_year), flash: { success: 'Accredited provider added' }
        end

        private

        def accredited_provider_form
          @accredited_provider_form ||= AccreditedProviderForm.new(current_user, provider)
        end
      end
    end
  end
end
