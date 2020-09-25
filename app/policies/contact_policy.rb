class ContactPolicy
  attr_reader :user, :contact

  def initialize(user, contact)
    @user = user
    @contact = contact
  end

  def update?
    user_is_admin_or_belongs_to_provider?
  end

private

  def user_belongs_to_the_provider?
    user.providers.include?(contact.provider)
  end

  def user_is_admin_or_belongs_to_provider?
    user_belongs_to_the_provider? || user.admin?
  end
end
