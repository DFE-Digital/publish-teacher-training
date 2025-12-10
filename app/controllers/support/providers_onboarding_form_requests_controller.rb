# frozen_string_literal: true

module Support
  class ProvidersOnboardingFormRequestsController < Support::ApplicationController
    before_action :set_request, only: %i[show update]

    def index
      # Fetches all requests ordered by creation date, paginated and passes to view to display as a table
      @pagy, @requests = pagy(ProvidersOnboardingFormRequest.order(created_at: :desc))
    end

    def new
      # Placeholder: form for creating a new onboarding request will be implemented in next ticket
    end

    def create
      # Placeholder: logic for creating a new onboarding request will be implemented in next ticket
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
      @request = ProvidersOnboardingFormRequest.find(params[:id])
    end

    def request_params
      # Strong params for onboarding request (to be used in next ticket)
      params.require(:providers_onboarding_form_request).permit(:form_name, :zendesk_link, :support_agent_id, :status)
    end
  end
end
