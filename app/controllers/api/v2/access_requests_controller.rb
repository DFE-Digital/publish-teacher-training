module API
  module V2
    class AccessRequestsController < API::V2::ApplicationController
      before_action :build_access_request
      before_action :build_requesting_user

      def approve
        @access_request.update_access(@access_request, @requesting_user)
        @access_request.completed!
      end

    private

      def build_access_request
        @access_request = authorize AccessRequest.find_by(id: params[:id])
      end

      def build_requesting_user
        @requesting_user = User.find_by!(id: @access_request.requester_id)
      end
    end
  end
end
