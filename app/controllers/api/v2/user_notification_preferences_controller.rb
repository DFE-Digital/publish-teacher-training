module API
  module V2
    class UserNotificationPreferencesController < API::V2::ApplicationController
      deserializable_resource :user_notification_preferences,
                              class: API::V2::DeserializableUserNotificationPreferences

      def show
        authorize user_notification_preferences = UserNotificationPreferences.new(user_id: params[:id])

        render jsonapi: user_notification_preferences
      end

      def update
        authorize user_notification_preferences = UserNotificationPreferences.new(user_id: params[:id])

        user_notification_preferences.update(enable_notifications: update_params[:enabled])

        render jsonapi: user_notification_preferences
      end

    private

      def update_params
        params.require(:user_notification_preferences)
          .permit(
            :enabled,
          )
      end
    end
  end
end
