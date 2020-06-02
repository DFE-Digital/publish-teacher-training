module UserAssociationsService
  class Create
    attr_reader :organisation, :user

    class << self
      def call(**args)
        new(args).call
      end
    end

    def initialize(organisation:, user:)
      @organisation = organisation
      @user = user
    end

    def call
      add_user_to_organistation
      update_user_notification_preferences
    end

    private_class_method :new

  private

    def add_user_to_organistation
      organisation.add_user(user)
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
