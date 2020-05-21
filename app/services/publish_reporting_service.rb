class PublishReportingService
  def initialize(recruitment_cycle_scope: RecruitmentCycle)
    @courses = recruitment_cycle_scope.courses
    @providers = recruitment_cycle_scope.providers
  end

  class << self
    def call(recruitment_cycle_scope:)
      new(recruitment_cycle_scope: recruitment_cycle_scope).call
    end
  end

  def call
    {
      users: user_breakdown,
      providers: provider_breakdown,
      courses: course_breakdown,
    }
  end

  private_class_method :new

private

  def days_ago
    @days_ago ||= 30.days.ago
  end

  def active_users
    @active_users ||= User.active
  end

  def recent_active_users
    @recent_active_users ||= active_users.last_login_since(days_ago)
  end

  def providers_with_recent_active_users_distinct_count
    @providers_with_recent_active_users_distinct_count ||= @providers
      .joins(:users)
      .merge(recent_active_users)
      .distinct
      .count
  end

  def recent_active_user_count_by_provider
    @recent_active_user_count_by_provider ||= recent_active_users
      .joins(:providers)          # Results include a user entry for _each_ matching provider
      .merge(@providers)          # Limit our scope to the current recruitment Cycle
      .group("provider_id")
      .count                      # Count the users for each provider
  end

  def grouped_providers_with_x_active_users
    @grouped_providers_with_x_active_users ||= recent_active_user_count_by_provider
      .group_by(&:second)             # Group the results by the number of users they have
      .transform_values(&:count)      # Count the results
  end

  def with_more_than_5_recent_active_users
    grouped_providers_with_x_active_users.keys.excluding(4, 3, 2, 1).sum { |k| grouped_providers_with_x_active_users[k] || 0 }
  end

  def user_count
    @user_count ||= User.count
  end

  def active_users_count
    @active_users_count ||= active_users.count
  end

  def recent_active_users_count
    @recent_active_users_count ||= recent_active_users.count
  end

  def provider_count
    @provider_count ||= @providers.count
  end

  def user_breakdown
    {
      total: {
        all: user_count,
        active_users: active_users_count,
        non_active_users: user_count - active_users_count,
      },
      recent_active_users: recent_active_users_count,
    }
  end

  def provider_breakdown
    {
      total: {
        all: provider_count,
        providers_with_non_active_users: (provider_count - providers_with_recent_active_users_distinct_count),
        providers_with_recent_active_users: providers_with_recent_active_users_distinct_count,
      },

      with_1_recent_active_users: grouped_providers_with_x_active_users[1] || 0,
      with_2_recent_active_users: grouped_providers_with_x_active_users[2] || 0,
      with_3_recent_active_users: grouped_providers_with_x_active_users[3] || 0,
      with_4_recent_active_users: grouped_providers_with_x_active_users[4] || 0,
      with_more_than_5_recent_active_users: with_more_than_5_recent_active_users,
    }
  end

  def course_breakdown
    courses_changed_recently = @courses.changed_at_since(days_ago)

    findable_courses = courses_changed_recently.findable.distinct
    open_courses = findable_courses.with_vacancies
    closed_courses = findable_courses.where.not(id: open_courses)

    courses_changed_recently_count = courses_changed_recently.count
    findable_courses_count = findable_courses.count

    {
      total_updated_recently: courses_changed_recently_count,
      updated_non_findable_recently: courses_changed_recently_count - findable_courses_count,

      updated_findable_recently: findable_courses_count,
      updated_open_courses_recently: open_courses.count,
      updated_closed_courses_recently: closed_courses.count,

      created_recently: @courses.created_at_since(days_ago).count,
    }
  end
end
