module Publish
  module Providers
    class AccessRequestsController < PublishController
      before_action :provider

      def new
        authorize AccessRequest

        @access_request = AccessRequestForm.new(user: current_user)
      end

      def create
        authorize AccessRequest

        @access_request = AccessRequestForm.new(params: access_request_params, user: current_user)

        if @access_request.save!
          redirect_to publish_provider_users_path(params[:code]),
            flash: { success: "Your request for access has been submitted" }
        else
          @errors = @access_request.errors.messages

          render :new
        end
      end

    private

      def access_request_params
        params.require(:publish_access_request_form).permit(
          *AccessRequestForm::FIELDS
        )
      end
    end
  end
end
