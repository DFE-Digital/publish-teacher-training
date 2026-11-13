# frozen_string_literal: true

module Support
  class ProvidersOnboardingFormRequestsController < Support::ApplicationController
    UPDATE_STATUS = { reject: "rejected" }.freeze
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
      if params[:status] == "accept"
        onboard_provider
      elsif updated_status && @onboarding_request.update(status: updated_status)
        redirect_to support_providers_onboarding_form_requests_path, flash: { success: t(".updated_status_message_html", updated_status: @onboarding_request.status_label, form_name: @onboarding_request.form_name) }
      else
        redirect_to support_providers_onboarding_form_requests_path, flash: { error: t(".error_message_html", form_name: @onboarding_request.form_name) }
      end
    end

  private

    def set_request
      # Finds the request by id param for show and update actions
      @onboarding_request = ProvidersOnboardingFormRequest.find(params[:id])
    end

    def onboard_provider
      result = Support::Providers::OnboardFromFormRequest.call(onboarding_request: @onboarding_request)

      if result.success?
        redirect_to support_recruitment_cycle_provider_path(result.provider.recruitment_cycle_year, result.provider),
                    flash: {
                      success: t(
                        "support.providers.onboard_from_form_request.success",
                        provider_name: result.provider.provider_name,
                        provider_code: result.provider.provider_code,
                      ),
                    }
      else
        result.errors.each do |error|
          @onboarding_request.errors.add(error[:attribute] || :base, error[:message])
        end
        @onboarding_request = @onboarding_request.decorate
        render :show, status: :unprocessable_entity
      end
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
