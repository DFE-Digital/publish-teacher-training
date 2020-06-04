module UserAssociationsService
  class Delete
    attr_reader :user, :organisations

    class << self
      def call(**args)
        new(args).call
      end
    end

    def initialize(user:, organisations:)
      @organisations = organisations
      @user = user
    end

    def call
      remove_access
      update_user_notification_preferences
    end

    private_class_method :new

  private

    def remove_access
      user.remove_access_to(organisations)
    end

    def update_user_notification_preferences
      user_notification_preferences = UserNotificationPreferences.new(user_id: user.id)
      return if user_notification_preferences.updated_at.nil?

      user_notification_preferences.update(
        enable_notifications: user_notification_preferences.enabled,
      )
    end
  end
end
