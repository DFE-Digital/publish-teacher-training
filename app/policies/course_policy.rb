class CoursePolicy
  attr_reader :user, :course

  class Scope
    attr_reader :user, :course, :scope

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

  def send_vacancies_updated_notification?
    user.present?
  end

  def can_update_funding_type?
    course.draft_or_rolled_over?
  end

  alias_method :preview?, :show?
  alias_method :details?, :show?
  alias_method :update?, :show?
  alias_method :edit?, :show?
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

  def permitted_new_course_attributes
    %i[
      accredited_body_code
      age_range_in_years
      applications_open_from
      funding_type
      is_send
      level
      qualification
      start_date
      study_mode
      can_sponsor_student_visa
      can_sponsor_skilled_worker_visa
    ]
  end

private

  def permitted_user_attributes
    permitted_new_course_attributes + %i[
      english
      maths
      science
      degree_grade
      additional_degree_subject_requirements
      degree_subject_requirements
      accept_pending_gcse
      accept_gcse_equivalency
      accept_english_gcse_equivalency
      accept_maths_gcse_equivalency
      accept_science_gcse_equivalency
      additional_gcse_equivalencies
    ]
  end

  def permitted_admin_attributes
    permitted_user_attributes + [:name]
  end
end
