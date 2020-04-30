class UserNotificationPolicy
  attr_reader :user, :user_notification

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        scope
          .where(provider_code: user.providers.pluck(:provider_code))
      end
    end
  end

  def initialize(user, user_notification)
    @user = user
    @user_notification = user_notification
  end

  def index?
    user.present?
  end

  def create?
    user_is_admin_or_belongs_to_accredited_body?
  end

private

  def user_is_admin_or_belongs_to_accredited_body?
    user_belongs_to_the_accredited_body? || user.admin?
  end

  def user_belongs_to_the_accredited_body?
    user.providers.include?(user_notification.provider)
  end
end
