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
    days_ago = 30.days.ago
    active_users = User.active
    active_users_last_30_days = active_users.last_login_since(days_ago)

    providers_with_active_users = @providers.with_users(active_users_last_30_days)

    providers_with_active_users_distinct_count = providers_with_active_users.distinct.count
    grouped_providers_with_x_active_users = providers_with_active_users.group(:id)
      .order(count_id: :desc)
      .count(:id)
      .group_by(&:second)

    user_count = User.count

    active_users_count = active_users.count
    active_users_last_30_days_count = active_users_last_30_days.count
    provider_count = @providers.count

    {
      users: {
        total: {
          all: user_count,
          active_users: active_users_count,
          non_active_users: user_count - active_users_count,
          active_users_last_30_days: active_users_last_30_days_count,
        },
      },
      providers: {
        total: {
          all: provider_count,
          providers_with_non_active_users: (provider_count - providers_with_active_users_distinct_count),
          providers_with_active_users: providers_with_active_users_distinct_count,
        },

        with_1_active_users: grouped_providers_with_x_active_users[1]&.count || 0,
        with_2_active_users: grouped_providers_with_x_active_users[2]&.count || 0,
        with_3_active_users: grouped_providers_with_x_active_users[3]&.count || 0,
        with_4_active_users: grouped_providers_with_x_active_users[4]&.count || 0,
        with_more_than_5_active_users: (grouped_providers_with_x_active_users.keys - [4, 3, 2, 1]).sum { |k| grouped_providers_with_x_active_users[k].count },
      },

      courses: course_activites(days_ago),
    }
  end

  private_class_method :new

private

  def user_total
    {
      all: user_count,
      active_users: active_users_count,
      non_active_users: user_count - active_users_count,
      active_users_last_30_days: active_users_last_30_days_count,
    }
  end

  def course_activites(days_ago)
    courses_changed_at_since = @courses.changed_at_since(days_ago)

    findable_courses = courses_changed_at_since.findable.distinct
    open_courses = findable_courses.with_vacancies
    closed_courses = findable_courses.where.not(id: open_courses)

    courses_changed_at_since_count = courses_changed_at_since.count
    findable_courses_count = findable_courses.count

    {
      total_updated_last_30_days: courses_changed_at_since_count,
      updated_non_findable_last_30_days: courses_changed_at_since_count - findable_courses_count,

      updated_findable_last_30_days: findable_courses_count,
      updated_open_courses_last_30_days: open_courses.count,
      updated_closed_courses_last_30_days: closed_courses.count,

      created_last_30_days: @courses.created_at_since(days_ago).count,
    }
  end
end
