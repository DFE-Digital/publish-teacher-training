class PerformanceDashboardService
  include ActionView::Helpers::NumberHelper

  include ServicePattern

  attr_accessor :recruitment_cycle

  def initialize(
    recruitment_cycle: RecruitmentCycle.current_recruitment_cycle
  )
    @recruitment_cycle = recruitment_cycle
  end

  def call
    self
  end

  def total_providers
    number_with_delimiter(reporting[:providers][:total][:all])
  end

  def total_courses
    number_with_delimiter(reporting[:courses][:total][:all_findable])
  end

  def total_users
    number_with_delimiter(reporting[:publish][:users][:total][:all])
  end

  def total_allocations
    number_with_delimiter(reporting[:allocations][:current][:total][:allocations])
  end

  def providers_published_courses
    number_with_delimiter(reporting[:providers][:training_providers][:findable_total][:open])
  end

  def providers_unpublished_courses
    number_with_delimiter(reporting[:providers][:training_providers][:findable_total][:closed])
  end

  def providers_accredited_bodies
    number_with_delimiter(reporting[:providers][:training_providers][:accredited_body][:open][:accredited_body])
  end

  def courses_total_open
    number_with_delimiter(reporting[:courses][:findable_total][:open])
  end

  def courses_total_closed
    number_with_delimiter(reporting[:courses][:findable_total][:closed])
  end

  def courses_total_draft
    number_with_delimiter(reporting[:courses][:total][:non_findable])
  end

  def allocations_requests(recruitment_cycle)
    number_with_delimiter(reporting[:allocations][recruitment_cycle.to_sym][:total][:allocations])
  end

  def allocations_number_of_places(recruitment_cycle)
    number_with_delimiter(reporting[:allocations][recruitment_cycle.to_sym][:total][:number_of_places])
  end

  def allocations_accredited_bodies(recruitment_cycle)
    number_with_delimiter(reporting[:allocations][recruitment_cycle.to_sym][:total][:distinct_accredited_bodies])
  end

  def allocations_providers(recruitment_cycle)
    number_with_delimiter(reporting[:allocations][recruitment_cycle.to_sym][:total][:distinct_providers])
  end

  def users_active
    number_with_delimiter(reporting[:publish][:users][:total][:active_users])
  end

  def users_not_active
    number_with_delimiter(reporting[:publish][:users][:total][:non_active_users])
  end

  def users_active_30_days
    number_with_delimiter(reporting[:publish][:users][:recent_active_users])
  end

  def rollover_total
    reporting[:rollover][:total]
  end

  def published_courses
    number_with_delimiter(rollover_total[:published_courses])
  end

  def new_courses_published
    number_with_delimiter(rollover_total[:new_courses_published])
  end

  def deleted_courses
    number_with_delimiter(rollover_total[:deleted_courses])
  end

  def existing_courses_in_draft
    number_with_delimiter(rollover_total[:existing_courses_in_draft])
  end

  def existing_courses_in_review
    number_with_delimiter(rollover_total[:existing_courses_in_review])
  end

private

  def reporting
    @reporting ||= StatisticService.reporting(recruitment_cycle: recruitment_cycle)
  end
end
