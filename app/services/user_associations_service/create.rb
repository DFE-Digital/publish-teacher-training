module UserAssociationsService
  class Create
    attr_reader :organisation, :user, :all_organisations

    class << self
      def call(**args)
        new(args).call
      end
    end

    def initialize(user:, organisation: nil, all_organisations: false)
      @organisation = organisation
      @user = user
      @all_organisations = all_organisations
    end

    def call
      add_user_to_organisations
      update_user_notification_preferences
    end

    private_class_method :new

  private

    def add_user_to_organisations
      if all_organisations
        add_user_to_all_organisations
      else
        add_user_to_a_single_organisation
      end
    end

    def add_user_to_a_single_organisation
      organisation.add_user(user)
    end

    def add_user_to_all_organisations
      user.organisations = Organisation.all
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
