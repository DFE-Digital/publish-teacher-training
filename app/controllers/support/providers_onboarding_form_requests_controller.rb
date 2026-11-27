# frozen_string_literal: true

module Support
  class ProvidersOnboardingFormRequestsController < Support::ApplicationController
    before_action :set_request, only: %i[show update]
    helper_method :request_editable?

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

      # Redirects to show page with success message if save is successful, otherwise re-renders the new form
      if @onboarding_request.save
        redirect_to support_providers_onboarding_form_request_path(@onboarding_request),
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
      if @onboarding_request.already_onboarded?
        redirect_to support_providers_onboarding_form_requests_path, flash: { error: error_flash(already_onboarded_message) }
        return
      end

      if params[:status] == "accept"
        onboard_provider
      elsif params[:status] == "reject" && reject_onboarding_request
        redirect_to support_providers_onboarding_form_requests_path, flash: { success: t(".rejected", provider_name: @onboarding_request.provider_name) }
      else
        redirect_to support_providers_onboarding_form_requests_path, flash: { error: error_flash(rejection_error_message) }
      end
    end

  private

    def set_request
      # Finds the request by id param for show and update actions
      @onboarding_request = ProvidersOnboardingFormRequest.find(params[:id])
    end

    # Organisation changes and the onboard or reject actions stay available until the request is finished.
    def request_editable?
      !(@onboarding_request.already_onboarded? || @onboarding_request.rejected?)
    end

    def reject_onboarding_request
      @onboarding_request.update(status: :rejected)
    end

    def rejection_error_message
      t(".error_message_html", form_name: @onboarding_request.form_name)
    end

    def already_onboarded_message
      t("support.providers.onboard_from_form_request.already_onboarded")
    end

    # The error summary reads message from a hash. A plain string leaves the heading with no text.
    def error_flash(message)
      { message: }
    end

    def onboard_provider
      if Support::Providers::OnboardFromFormRequest.call(onboarding_request: @onboarding_request)
        provider = @onboarding_request.provider
        redirect_to support_recruitment_cycle_provider_path(provider.recruitment_cycle_year, provider),
                    flash: {
                      success: t(
                        "support.providers.onboard_from_form_request.success",
                        provider_name: provider.provider_name,
                      ),
                    }
      else
        @onboarding_request = @onboarding_request.decorate
        render :show, status: :unprocessable_content
      end
    end

    def request_params
      # Strong params for onboarding request
      params.require(:providers_onboarding_form_request).permit(:form_name, :zendesk_link, :support_agent_id)
    end
  end
end
