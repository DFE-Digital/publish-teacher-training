# frozen_string_literal: true

module Publish
  class ProviderOnboardingController < ApplicationController
    skip_after_action :verify_authorized # No authorization required for provider onboarding form
    before_action :set_onboarding_request

    def show; end

    # Handles the submission of the onboarding form by the provider
    def update
      @onboarding_request.assign_attributes(onboarding_request_params)
      @onboarding_request.status = "submitted"

      if @onboarding_request.save
        redirect_to publish_provider_onboarding_submitted_path(uuid: @onboarding_request.uuid)
      else
        render :show
      end
    end

    # Page displayed after successful submission of the onboarding form by the provider
    def submitted; end

  private

    def set_onboarding_request
      @onboarding_request = ProvidersOnboardingFormRequest.find_by!(uuid: params[:uuid])
    end

    # Strong params for provider onboarding form submission
    def onboarding_request_params
      params.require(:providers_onboarding_form_request).permit(
        :provider_name, :email_address, :first_name, :last_name,
        :address_line_1, :address_line_2, :address_line_3, :town_or_city, :county, :postcode, :telephone, :contact_email_address,
        :website, :ukprn, :accredited_provider, :urn
      )
    end
  end
end
