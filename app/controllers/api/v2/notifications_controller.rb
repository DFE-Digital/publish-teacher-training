module API
  module V2
    class NotificationsController < API::V2::ApplicationController
      deserializable_resource :user_notification,
                              class: API::V2::DeserializableNotification
      def create
        @current_user.providers.where(accrediting_provider: :accredited_body).map do |provider|
          authorize @notification = @current_user.user_notifications.find_or_initialize(provider.provider_code)
          @notification.course_create = user_notification_params[:course_create]
          @notification.course_update = user_notification_params[:course_update]
        end

        if @current_user.save
          render jsonapi: @current_user.user_notifications, include: params[:include], status: :created
        else
          render jsonapi_errors: @current_user.errors, status: :unprocessable_entity
        end
      end

    private

      def user_notification_params
        params.require(:user_notification)
              .permit(
                :course_create,
                :course_update,
              )
      end
    end
  end
end
