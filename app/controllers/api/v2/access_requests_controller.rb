module API
  module V2
    class AccessRequestsController < API::V2::ApplicationController
      before_action :build_access_request, only: :approve

      def approve
        result = AccessRequestApprovalService.call(@access_request)

        render status: 200, json: { result: result }
      end

      def index
        authorize AccessRequest
        @access_requests = AccessRequest.requested

        render status: 200, json: @access_requests
      end

    private

      def build_access_request
        @access_request = authorize AccessRequest.requested.find(params[:id])
      end
    end
  end
end
