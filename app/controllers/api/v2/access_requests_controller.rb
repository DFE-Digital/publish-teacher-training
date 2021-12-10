module API
  module V2
    class AccessRequestsController < API::V2::ApplicationController
      deserializable_resource :access_request,
                              only: %i[create],
                              class: API::V2::DeserializableAccessRequest

      before_action :authorize_access_request

      def approve
        result = AccessRequestApprovalService.call(access_request(:requested))

        render status: :ok, json: { result: result }
      end

      def show
        if access_request.discarded?
          render jsonapi: nil, status: :not_found
        else
          render jsonapi: access_request, include: params[:include]
        end
      end

      def index
        @access_requests = AccessRequest.requested.includes(:requester).by_request_date

        render jsonapi: @access_requests, include: params[:include]
      end

      def create
        @access_request = AccessRequest.new(access_request_params)
        @access_request.add_additional_attributes(@access_request.requester_email)

        if @access_request.valid?
          render jsonapi: @access_request
        else
          render jsonapi_errors: @access_request.errors, status: :unprocessable_entity
        end
      end

      def destroy
        access_request.discard
      end

    private

      def authorize_access_request
        authorize AccessRequest
      end

      def access_request(scope = :all)
        @access_request ||= AccessRequest.public_send(scope).find(params[:id])
      end

      def access_request_params
        params.require(:access_request).permit(
          :email_address,
          :first_name,
          :last_name,
          :reason,
          :requester_email,
        ).with_defaults(requester_email: current_user.email)
      end
    end
  end
end
