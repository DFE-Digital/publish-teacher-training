# frozen_string_literal: true

module Support
  class ProvidersOnboardingFormRequestsController < Support::ApplicationController
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
      # Updates the status of the onboarding request based on action taken by support agent
      updated_status =
        case params[:status]
        when "accept" then "closed"
        when "reject" then "rejected"
        else params[:status]
        end

      if @onboarding_request.update(status: updated_status)
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

    def request_params
      # Strong params for onboarding request
      params.require(:providers_onboarding_form_request).permit(:form_name, :zendesk_link, :support_agent_id)
    end

    # Params for updating onboarding form details (to be used in next ticket)
    def onboarding_request_params
      params.require(:providers_onboarding_form_request).permit(
        :provider_name, :zendesk_link, :email_address, :first_name, :last_name,
        :address_line_1, :town_or_city, :postcode, :telephone, :contact_email_address,
        :website, :ukprn, :accredited_provider, :urn, :support_agent_id
      )
    end
  end
end
