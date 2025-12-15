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
      @admin_users = User.where(admin: true).order(:first_name, :last_name)
    end

    def create
      @onboarding_request = ProvidersOnboardingFormRequest.new(request_params)
      @onboarding_request.uuid = SecureRandom.uuid
      @onboarding_request.status = "pending"
      @admin_users = User.where(admin: true).order(:first_name, :last_name)
      @onboarding_request.form_link = publish_provider_onboarding_form_url(uuid: @onboarding_request.uuid)

      if @onboarding_request.save
        redirect_to support_providers_onboarding_form_requests_path, flash: { success: t(".success_message_html", form_link: @onboarding_request.form_link) }
      else
        render :new
      end
    end

    def show
      # Placeholder: details view for a single onboarding request will be implemented later
    end

    def update
      # Placeholder: logic for updating an onboarding request will be implemented in next ticket
    end

  private

    def set_request
      # Finds the request by id param for show and update actions
      @onboarding_request = ProvidersOnboardingFormRequest.find(params[:id])
    end

    def request_params
      # Strong params for onboarding request (to be used in next ticket)
      params.require(:providers_onboarding_form_request).permit(:form_name, :zendesk_link, :support_agent_id)
    end

    def onboarding_request_params
      params.require(:providers_onboarding_form_request).permit(
        :provider_name, :zendesk_link, :email_address, :first_name, :last_name,
        :address_line_1, :town_or_city, :postcode, :telephone, :contact_email_address,
        :website, :ukprn, :accredited_provider, :urn, :support_agent_id
      )
    end
  end
end
