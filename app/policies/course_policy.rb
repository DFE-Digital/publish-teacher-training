class CoursePolicy
  attr_reader :user, :course

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
          .where(provider_id: user.providers.pluck(:id))
          .or(Course.where(accrediting_provider_code: user.providers.pluck(:provider_code)))
      end
    end
  end

  def initialize(user, course)
    @user = user
    @course = course
  end

  def index?
    user.present?
  end

  def show?
    user.admin? || user.providers.include?(course.provider)
  end

  alias_method :update?, :show?
  alias_method :destroy?, :show?
  alias_method :publish?, :update?
  alias_method :publishable?, :update?
  alias_method :new?, :index?
  alias_method :withdraw?, :show?
end
