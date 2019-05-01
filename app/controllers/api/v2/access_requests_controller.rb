module API
  module V2
    class AccessRequestsController < API::V2::ApplicationController
      before_action :build_access_request

      def approve
        result = AccessRequestApprovalService.call(@access_request)

        render status: 200, json: { result: result }
      end

    private

      def build_access_request
        @access_request = authorize AccessRequest.requested.find(params[:id])
      end
    end
  end
end
