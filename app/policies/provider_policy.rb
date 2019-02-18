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
end
