class RecruitmentCyclePolicy
  attr_reader :user, :recruitment_cycle

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      # If a user is logged in, they can view all recruitment cycles
      scope
    end
  end

  def initialize(user, recycle)
    @user = user
    @recruitment_cycle = recycle
  end

  def show?
    user.present?
  end
end
