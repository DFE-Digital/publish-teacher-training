module API
  module V2
    class AccessRequestsController < API::V2::ApplicationController
      deserializable_resource :access_request, only: %i[create]
      before_action :build_access_request, only: :approve

      def approve
        result = AccessRequestApprovalService.call(@access_request)

        render status: 200, json: { result: result }
      end

      def show
        authorize AccessRequest
        @access_request = AccessRequest.find(params[:id])

        render jsonapi: @access_request, include: [:requester]
      end

      def index
        authorize AccessRequest
        @access_requests = AccessRequest.requested.includes(:requester)

        render jsonapi: @access_requests, include: params[:include]
      end

      def create
        authorize AccessRequest # todo, generalise admin auth
        access_request = AccessRequest.new(access_request_params)
        access_request.update(requester: @current_user,
                              request_date_utc: Time.now.utc,
                              status: :requested)

        render jsonapi: access_request
      end

    private

      def build_access_request
        @access_request = authorize AccessRequest.requested.find(params[:id])
      end

      def access_request_params
        params.require(:access_request).permit(:email_address, :first_name, :last_name, :organisation, :reason)
      end
    end
  end
end
