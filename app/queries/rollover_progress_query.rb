class RolloverProgressQuery
  include ActiveModel::Model

  attr_reader :previous_target_cycle, :target_cycle

  def initialize(target_cycle:)
    @target_cycle = target_cycle
    @previous_target_cycle = RecruitmentCycle.find_by(year: @target_cycle.year.to_i - 1)
  end

  def remaining_to_rollover_count
    total_eligible_providers_count - rolled_over_providers_count
  end

  delegate :count, to: :providers_without_published_courses, prefix: true

  delegate :count, to: :total_eligible_providers, prefix: true

  delegate :count, to: :rolled_over_providers, prefix: true

  delegate :count, to: :total_eligible_courses, prefix: true

  delegate :count, to: :rolled_over_courses, prefix: true

  def rollover_percentage
    return 0 if total_eligible_providers_count.zero? || rolled_over_providers_count.zero?

    (rolled_over_providers_count.to_f / total_eligible_providers_count * 100).round(2)
  end

  def providers_without_published_courses
    @previous_target_cycle.providers.where.not(
      id: total_eligible_providers.select(:id),
    ).distinct
  end

  def total_eligible_providers
    @total_eligible_providers ||= @previous_target_cycle.providers.where(
      id: providers_with_own_rollable_courses.select(:id),
    ).or(
      @previous_target_cycle.providers.where(
        id: providers_with_rollable_accredited_courses.select(:id),
      ),
    ).distinct
  end

  def total_eligible_courses
    @previous_target_cycle
      .courses
      .joins(:latest_enrichment)
      .where(course_enrichment: { status: %i[published withdrawn] })
      .where(provider_id: total_eligible_providers.select(:id)).distinct
  end

  def rolled_over_courses
    @target_cycle.courses.where("course.created_at < ?", @target_cycle.application_start_date)
  end

  def rolled_over_providers
    @rolled_over_providers ||= @target_cycle.providers.where("created_at < ?", @target_cycle.application_start_date)
  end

private

  def providers_with_own_rollable_courses
    @previous_target_cycle.providers
      .joins(courses: :latest_enrichment)
      .where(course_enrichment: { status: %i[published withdrawn] })
      .distinct
  end

  def providers_with_rollable_accredited_courses
    @previous_target_cycle.providers
      .joins(accredited_courses: :latest_enrichment)
      .where(course_enrichment: { status: %i[published withdrawn] })
      .distinct
  end
end
