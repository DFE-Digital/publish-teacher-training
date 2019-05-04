module API
  module V2
    class AccessRequestsController < API::V2::ApplicationController
      before_action :build_access_request, except: :list
      before_action :build_list_of_access_requests, except: :approve

      def approve
        result = AccessRequestApprovalService.call(@access_request)

        render status: 200, json: { result: result }
      end

      def list
        render status: 200, json: @list_of_access_requests
      end

    private

      def build_access_request
        @access_request = authorize AccessRequest.requested.find(params[:id])
      end

      def build_list_of_access_requests
        @list_of_access_requests = authorize AccessRequest.requested.all
      end
    end
  end
end
