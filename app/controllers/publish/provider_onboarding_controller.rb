# frozen_string_literal: true

module Publish
  class ProviderOnboardingController < ApplicationController
    # Public link: skip authentication and authorisation for provider onboarding form
    skip_before_action :authenticate, raise: false
    skip_after_action :verify_authorized
    before_action :set_onboarding_request
    before_action :ensure_can_edit, only: %i[update]

    def show; end

    # Handles the submission of the onboarding form by the provider
    def update
      @onboarding_request.assign_attributes(onboarding_request_params)

      # If the form is being submitted for the first time, update status to 'submitted'.
      # Admin user edits keep the existing status.
      if pending_for_public?
        @onboarding_request.status = "submitted"
      end

      if @onboarding_request.save
        redirect_to publish_provider_onboarding_submitted_path(uuid: @onboarding_request.uuid)
      else
        render :show
      end
    end

    # Page displayed after successful submission of the onboarding form by the provider
    def submitted; end

    helper_method :pending_for_public?, :admin_user?

  private

    def set_onboarding_request
      @onboarding_request = ProvidersOnboardingFormRequest.find_by!(uuid: params[:uuid])
    end

    # Check if the onboarding request is still pending for public users
    def pending_for_public?
      @onboarding_request.status == "pending"
    end

    # Ensure that only pending forms can be edited by the public or admin users can edit the form regardless of status
    def ensure_can_edit
      return if editable_by_current_user?

      flash.now[:info] = "This onboarding form has already been submitted and can no longer be edited. Please contact the support team for further assistance."
      render :show, status: :not_found
    end

    # Check if the form is editable by the current user
    def editable_by_current_user?
      pending_for_public? || admin_user?
    end

    # Check if the current user is an admin user
    def admin_user?
      current_user&.admin?
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
