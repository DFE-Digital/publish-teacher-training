module UserAssociationsService
  class Delete
    attr_reader :user, :providers

    class << self
      def call(**args)
        new(**args).call
      end
    end

    def initialize(user:, providers:)
      @providers = Array(providers)
      @user = user
    end

    def call
      remove_access
      update_user_notification_preferences
      send_remove_user_from_provider_email
    end

    private_class_method :new

  private

    def send_remove_user_from_provider_email
      providers.each do |provider|
        RemoveUserFromOrganisationMailer.remove_user_from_provider_email(recipient: user, provider:).deliver_later
      end
    end

    def remove_access
      user.remove_access_to(providers)
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
