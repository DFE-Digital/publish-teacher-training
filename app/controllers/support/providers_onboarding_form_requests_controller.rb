# frozen_string_literal: true

module Support
  class ProvidersOnboardingFormRequestsController < Support::ApplicationController
    before_action :set_request, only: %i[show update]
    def index
      # fetches all requests ordered by creation date, paginated and passes to view to display as a table
      @pagy, @requests = pagy(ProvidersOnboardingFormRequest.order(created_at: :desc))
    end

    def new
      # creates a blank request object for the new form
      @request = ProvidersOnboardingFormRequest.new
    end

    def create
      # creates a new request with form params, sets status to pending and uuid, saves and redirects to index with notice on success or re-renders new on failure

      @request = ProvidersOnboardingFormRequest.new(request_params)
      @request.status = "pending"
      @request.uuid = SecureRandom.uuid

      if @request.save
        @request.update(form_link: publish_onboarding_form_url(@request.uuid))
        redirect_to support_providers_onboarding_form_requests_path,
                    flash: { success: "Request created successfully. Provider link: #{@request.form_link}" } # pass form link in flash for display
      else
        render :new
      end
    end

    def show; end

    def update
      # updates the request with form params, redirects to index with notice on success or re-renders show on failure
      if @request.update(request_params)
        redirect_to support_providers_onboarding_form_requests_path,
                    flash: { success: "Request updated successfully. Provider link: #{@request.form_link}" } # pass form link in flash for display
      else
        render :show
      end
    end

  private

    def set_request
      # finds the request by id param for show and update actions and assigns to @request
      @request = ProvidersOnboardingFormRequest.find(params[:id])
    end

    def request_params
      params.require(:providers_onboarding_form_request).permit(:form_name, :zendesk_link, :support_agent_id, :status)
    end
  end
end
