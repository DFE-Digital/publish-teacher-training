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
  alias_method :publish?, :update?
end
