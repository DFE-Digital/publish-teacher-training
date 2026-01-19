# frozen_string_literal: true

module Support
  class ProvidersOnboardingFormRequestsController < Support::ApplicationController
    UPDATE_STATUS = { accept: "closed", reject: "rejected" }.freeze
    before_action :set_request, only: %i[show update]

    def index
      # Fetches all requests ordered by creation date, paginated and passes to view to display as a table
      @pagy, @onboarding_requests = pagy(ProvidersOnboardingFormRequest.includes(:support_agent).order(created_at: :desc))
    end

    def new
      @onboarding_request = ProvidersOnboardingFormRequest.new
      @admin_users = User.where(admin: true).order(:email)
    end

    def create
      @onboarding_request = ProvidersOnboardingFormRequest.new(request_params)

      # Fetches admin users for support agent selection in the form which is re-rendered if save fails due to validation errors
      @admin_users = User.where(admin: true).order(:email)

      if @onboarding_request.save
        redirect_to support_providers_onboarding_form_requests_path,
                    flash: { success: t(".success_message_html", form_name: @onboarding_request.form_name) }
      else
        render :new
      end
    end

    def show
      # Finds the request by id param for display in the view
      @onboarding_request = ProvidersOnboardingFormRequest.find(params[:id]).decorate
    end

    def update
      # Redirects to listing page with success or error message based on whether the update was successful
      if updated_status && @onboarding_request.update(status: updated_status)
        redirect_to support_providers_onboarding_form_requests_path, flash: { success: t(".updated_status_message_html", updated_status: updated_status.humanize, form_name: @onboarding_request.form_name) }
      else
        redirect_to support_providers_onboarding_form_requests_path, flash: { error: t(".error_message_html", form_name: @onboarding_request.form_name) }
      end
    end

  private

    def set_request
      # Finds the request by id param for show and update actions
      @onboarding_request = ProvidersOnboardingFormRequest.find(params[:id])
    end

    # Determines the updated status based on the status param passed in the request from the details/show page
    def updated_status
      @updated_status ||= UPDATE_STATUS.fetch(params[:status].to_sym, nil) # nil will be returned if no status
    end

    def request_params
      # Strong params for onboarding request
      params.require(:providers_onboarding_form_request).permit(:form_name, :zendesk_link, :support_agent_id)
    end
  end
end
