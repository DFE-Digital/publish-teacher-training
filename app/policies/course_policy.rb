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
          .or(Course.where(accredited_body_code: user.providers.pluck(:provider_code)))
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

  def send_vacancies_filled_notification?
    user.present?
  end

  alias_method :update?, :show?
  alias_method :destroy?, :show?
  alias_method :publish?, :update?
  alias_method :publishable?, :update?
  alias_method :new?, :index?
  alias_method :withdraw?, :show?

  def permitted_attributes
    if user.admin?
      permitted_admin_attributes
    else
      permitted_user_attributes
    end
  end

private

  def permitted_user_attributes
    %i[
      english
      maths
      science
      qualification
      age_range_in_years
      start_date
      applications_open_from
      study_mode
      is_send
      accredited_body_code
      funding_type
      level
    ]
  end

  def permitted_admin_attributes
    permitted_user_attributes + [:name]
  end
end
