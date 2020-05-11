class ProviderPolicy
  attr_reader :user, :provider

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
        scope.where(id: user.providers)
      end
    end
  end

  def initialize(user, provider)
    @user = user
    @provider = provider
  end

  def index?
    user.present?
  end

  def show?
    user.admin? || user.providers.include?(provider)
  end

  def create?
    user.admin?
  end

  def suggest?
    user.present?
  end

  alias_method :can_list_sites?, :show?
  alias_method :can_create_course?, :show?
  alias_method :update?, :show?
  alias_method :build_new?, :show?
  alias_method :can_list_training_providers?, :show?
end
