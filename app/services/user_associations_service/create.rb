module UserAssociationsService
  class Create
    include RolloverHelper

    attr_reader :provider, :user, :all_providers

    class << self
      def call(**args)
        new(**args).call
      end
    end

    def initialize(user:, provider: nil, all_providers: false)
      @provider = provider
      @user = user
      @all_providers = all_providers
    end

    def call
      add_user_to_providers
      update_user_notification_preferences
    end

    private_class_method :new

  private

    def add_user_to_providers
      if all_providers
        add_user_to_all_providers
      else
        add_user_to_a_single_provider
        send_user_added_to_provider_email
      end
    end

    def add_user_to_a_single_provider
      add_user_to_provider_in_current_cycle

      if rollover_active?
        add_user_to_provider_in_next_cycle
      end
    end

    def add_user_to_provider_in_current_cycle
      provider.users << user
    end

    def add_user_to_provider_in_next_cycle
      RecruitmentCycle.next.providers.find_by(provider_code: provider.provider_code).users << user
    end

    def send_user_added_to_provider_email
      NewUserAddedBySupportTeamMailer.user_added_to_provider_email(recipient: user).deliver_later
    end

    def add_user_to_all_providers
      user.providers = Provider.all
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
