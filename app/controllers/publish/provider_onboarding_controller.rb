# frozen_string_literal: true

module Publish
  class ProviderOnboardingController < ApplicationController
    # Public link: skip authentication and authorisation for provider onboarding form
    skip_before_action :authenticate, only: %i[show update submitted], raise: false
    skip_after_action :verify_authorized, only: %i[show update submitted]
    before_action :set_onboarding_request
    before_action :ensure_can_edit, only: %i[update]

    def show; end

    # Handles the submission of the onboarding form by the provider
    def update
      @onboarding_request.assign_attributes(onboarding_request_params)

      # Only first-time public submissions should move to submitted
      @onboarding_request.status = :submitted if pending_for_public?

      # Save and redirect to submitted page or re-render the form with errors
      if @onboarding_request.save
        redirect_to submitted_publish_provider_onboarding_path(uuid: @onboarding_request.uuid)
      else
        render :show
      end
    end

    # Page displayed after successful submission of the onboarding form by the provider
    def submitted; end

    helper_method :pending_for_public?, :admin_user?, :editable_by_current_user?, :show_already_submitted_notice?

  private

    def set_onboarding_request
      @onboarding_request = ProvidersOnboardingFormRequest.find_by!(uuid: params[:uuid])
    end

    # Check if the onboarding request is still pending for public users (i.e. not yet submitted)
    def pending_for_public?
      @onboarding_request.pending?
    end

    # If someone tries to submit an already-submitted form and they aren’t an admin this runs
    # Public users cannot submit again — the form becomes locked. Only admin users can bypass that.
    def ensure_can_edit
      return if editable_by_current_user?

      flash.now[:info] = "This onboarding form has already been submitted and can no longer be edited. Please contact the support team for further assistance."
      render :show, status: :unprocessable_entity
    end

    # Check if the form is editable by the current user
    # Public users can edit only if the form is pending and Admin users can edit regardless of status
    def editable_by_current_user?
      pending_for_public? || admin_user?
    end

    # Check if the current user is an admin user
    def admin_user?
      current_user&.admin?
    end

    def show_already_submitted_notice?
      flash[:info].blank? &&
        @onboarding_request.errors.empty? &&
        !(pending_for_public? || admin_user?)
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
