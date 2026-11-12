# frozen_string_literal: true

module Publish
  class ProviderOnboardingController < ApplicationController
    # Fixed token for support Change links. The redirect target is built from the
    # onboarding request, so this value cannot be used as an open redirect.
    SUPPORT_RETURN_TO = "support"

    # Public link: skip authentication and authorisation for provider onboarding form
    skip_before_action :authenticate, only: %i[show update submitted check_answers confirm], raise: false
    skip_after_action :verify_authorized, only: %i[show update submitted check_answers confirm]
    before_action :set_onboarding_request
    before_action :ensure_can_edit, only: %i[update confirm]

    def show; end

    # Handles the submission of the onboarding form by the provider
    def update
      # Update the onboarding request with submitted form details and validate provider fields.
      # Support users who came from the request page return there. Everyone else goes to check your answers.
      if @onboarding_request.update_form_details(onboarding_request_params)
        redirect_to after_update_path
      else
        render :show
      end
    end

    def check_answers; end

    def confirm
      # Confirm the onboarding form and mark the request as submitted
      if @onboarding_request.submit
        redirect_to submitted_publish_provider_onboarding_path(uuid: @onboarding_request.uuid)
      else
        # if submission fails (e.g. validations), re-render the check your answers page with errors
        render :check_answers
      end
    end

    # Page displayed after successful submission of the onboarding form by the provider
    def submitted; end

    helper_method :pending_for_public?, :admin_user?, :editable_by_current_user?, :show_already_submitted_notice?, :return_to_support?

  private

    def set_onboarding_request
      # Find the onboarding request by UUID and decorate it for use in views (ProvidersOnboardingFormRequestDecorator)
      @onboarding_request = ProvidersOnboardingFormRequest.find_by!(uuid: params[:uuid]).decorate
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

    # Support users who opened the form from the request page return there after a
    # successful save. Anyone else, and any other return_to value, continues to check your answers.
    def return_to_support?
      admin_user? && params[:return_to] == SUPPORT_RETURN_TO
    end

    def after_update_path
      if return_to_support?
        support_providers_onboarding_form_request_path(@onboarding_request)
      else
        check_answers_publish_provider_onboarding_path(uuid: @onboarding_request.uuid)
      end
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
        :website, :ukprn, :accredited_provider, :accredited_provider_number, :provider_type, :urn
      )
    end
  end
end
