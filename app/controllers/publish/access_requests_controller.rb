module Publish
  class AccessRequestsController < PublishController
    before_action -> { authorize(access_request) }, except: :index

    def index
      authorize(AccessRequest)

      @access_requests = AccessRequest.requested.includes(:requester)
    end

    def approve
      access_request.approved!
      flash[:success] = "Successfully approved request"
      redirect_to inform_publisher_publish_access_request_path
    end

    def inform_publisher; end

    def confirm; end

    def destroy
      access_request.destroy
      flash[:success] = "Successfully deleted the Access Request"
      redirect_to publish_access_requests_path
    end

  private

    def access_request
      @access_request ||= AccessRequest.includes(:requester, requester: [:organisations]).find(params[:id])
    end
  end
end
