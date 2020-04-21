class AllocationPolicy
  attr_reader :user, :allocation

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
          .where(accredited_body_id: user.providers.pluck(:id))
      end
    end
  end

  def initialize(user, allocation);
    @allocation = allocation
    @user = user
  end

  def index?
    user.present?
  end

  def create?
    user.admin? || user_belongs_to_the_accredited_body?
  end

private

  def user_belongs_to_the_accredited_body?
    user.providers.include?(allocation.accredited_body)
  end
end
