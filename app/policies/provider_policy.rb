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

  def show_any?
    user.present?
  end

  def create?
    user.admin?
  end

  def suggest?
    user.present?
  end

  def suggest_any?
    user.present?
  end

  def can_show_training_provider?
    return true if user.admin?

    accredited_bodies_codes = provider.accredited_bodies.map { |ab| ab[:provider_code] }
    user_provider_codes = user.providers.pluck(:provider_code)

    !(accredited_bodies_codes & user_provider_codes).compact.empty?
  end

  alias_method :can_list_sites?, :show?
  alias_method :can_create_course?, :show?
  alias_method :update?, :show?
  alias_method :build_new?, :show?
  alias_method :can_list_training_providers?, :show?
end
