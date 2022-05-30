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

  alias_method :new?, :create?
  alias_method :index?, :approve?
  alias_method :show?, :approve?
  alias_method :inform_publisher?, :approve?
  alias_method :confirm?, :approve?
  alias_method :destroy?, :approve?
end
