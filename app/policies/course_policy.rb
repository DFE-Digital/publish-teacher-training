class CoursePolicy
  attr_reader :user, :course

  def initialize(user, course)
    @user = user
    @course = course
  end

  def index?
    user.present?
  end

  def show?
    user.providers.include? course.provider
  end

  alias_method :update?, :show?
  alias_method :destroy?, :show?
  alias_method :sync_with_search_and_compare?, :update?
  alias_method :publish?, :update?
  alias_method :publishable?, :update?
  alias_method :new?, :index?
end
