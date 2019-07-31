class ProviderPolicy
  attr_reader :user, :provider

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(id: user.providers)
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
    user.providers.include?(provider)
  end

  alias_method :can_list_courses?, :show?
  alias_method :can_list_sites?, :show?
  alias_method :update?, :show?
  alias_method :publish?, :show?
  alias_method :publishable?, :show?
  alias_method :sync_courses_with_search_and_compare?, :show?
end
