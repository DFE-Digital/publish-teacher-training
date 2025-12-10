# frozen_string_literal: true

module Support
  class ProvidersOnboardingFormRequestsController < Support::ApplicationController
    def index
      @pagy, @requests = pagy(ProvidersOnboardingFormRequest.order(created_at: :desc))
    end

    def new
      @request = ProvidersOnboardingFormRequest.new
    end

    def create
      @request = ProvidersOnboardingFormRequest.new(request_params)
      @request.status = "pending"
      @request.uuid = SecureRandom.uuid

      if @request.save
        redirect_to support_providers_onboarding_form_requests_path, notice: "Request created successfully."
      else
        render :new
      end
    end

    def show; end

    def update
      if @request.update(request_params)
        redirect_to support_providers_onboarding_form_request_path(@request), notice: "Request updated successfully."
      else
        render :show
      end
    end

  private

    def set_request
      @request = ProvidersOnboardingFormRequest.find(params[:uuid])
    end

    def request_params
      params.require(:providers_onboarding_form_request).permit(:form_name, :zendesk_link, :support_agent_id, :status)
    end
  end
end
