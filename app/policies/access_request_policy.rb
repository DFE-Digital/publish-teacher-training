class AccessRequestPolicy
  attr_reader :user, :access_request

  def initialize(user, _access_request)
    @user = user
  end

  def approve?
    @user.admin?
  end

  def create?
    @user.present?
  end

  alias_method :index?, :approve?
  alias_method :show?, :approve?
end
