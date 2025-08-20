class RolloverProgressQuery
  include ActiveModel::Model

  attr_reader :previous_target_cycle, :target_cycle

  def initialize(target_cycle:)
    @target_cycle = target_cycle
    @previous_target_cycle = RecruitmentCycle.find_by(year: @target_cycle.year.to_i - 1)
  end

  def remaining_to_rollover_count
    eligible_providers_count - rolled_over_providers_count
  end

  delegate :count, to: :providers_without_published_courses, prefix: true

  delegate :count, to: :eligible_providers, prefix: true

  delegate :count, to: :rolled_over_providers, prefix: true

  delegate :count, to: :eligible_courses, prefix: true

  delegate :count, to: :eligible_study_sites, prefix: true

  delegate :count, to: :rolled_over_study_sites, prefix: true

  delegate :count, to: :rolled_over_courses, prefix: true

  delegate :count, to: :eligible_partnerships, prefix: true

  delegate :count, to: :rolled_over_partnerships, prefix: true

  def rollover_percentage
    return 0 if eligible_providers_count.zero? || rolled_over_providers_count.zero?

    (rolled_over_providers_count.to_f / eligible_providers_count * 100).round(2)
  end

  def providers_without_published_courses
    @previous_target_cycle.providers
    .where.not(id: eligible_providers.select(:id))
    .distinct
  end

  def eligible_providers
    @eligible_providers ||= @previous_target_cycle.providers.where(
      id: providers_with_own_rollable_courses.select(:id),
    ).or(
      @previous_target_cycle.providers.where(
        id: providers_with_rollable_accredited_courses.select(:id),
      ),
    ).distinct
  end

  def eligible_courses
    @previous_target_cycle
      .courses
      .joins(:latest_enrichment)
      .where(course_enrichment: { status: %i[published withdrawn] })
      .where(provider_id: eligible_providers.select(:id)).distinct
  end

  def eligible_partnerships
    ProviderPartnership
    .includes(:training_provider, :accredited_provider)
    .where(
      "accredited_provider_id IN (:ids) OR training_provider_id IN (:ids)",
      ids: eligible_providers.select(:id),
    )
    .where.not(
      training_provider_id: providers_without_published_courses.select(:id),
    )
    .where.not(
      training_provider_id: previous_cycle_discarded_providers.select(:id),
    )
    .where.not(
      accredited_provider_id: previous_cycle_discarded_providers.select(:id),
    )
  end

  def eligible_study_sites
    @eligible_study_sites ||= Site.joins(:provider)
      .where(provider: { recruitment_cycle: @previous_target_cycle })
      .where(site_type: "study_site")
      .where(provider_id: eligible_providers.select(:id))
  end

  def rolled_over_study_sites
    @rolled_over_study_sites ||= @target_cycle.study_sites
  end

  def rolled_over_partnerships
    ProviderPartnership.includes(:training_provider, :accredited_provider).where(
      "accredited_provider_id IN (:id) OR training_provider_id IN (:id)",
      id: @target_cycle.providers.select(:id),
    )
  end

  def partnerships_diff
    previous_pairs = eligible_partnerships.map do |partnership|
      [
        partnership.training_provider.provider_code,
        partnership.accredited_provider.provider_code,
      ]
    end

    rolled_over_pairs = rolled_over_partnerships.map do |partnership|
      [
        partnership.training_provider.provider_code,
        partnership.accredited_provider.provider_code,
      ]
    end

    previous_pairs - rolled_over_pairs
  end

  def rolled_over_courses
    @target_cycle.courses.where("course.created_at < ?", @target_cycle.application_start_date).order(created_at: :asc)
  end

  def rolled_over_providers
    @rolled_over_providers ||= @target_cycle.providers.where("created_at < ?", @target_cycle.application_start_date)
  end

  def not_rolled_over_providers_codes
    eligible_provider_codes = eligible_providers.pluck(:provider_code)
    rolled_over_provider_codes = @target_cycle.providers.pluck(:provider_code)

    eligible_provider_codes - rolled_over_provider_codes
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

  def previous_cycle_discarded_providers
    Provider
      .unscoped
      .where(recruitment_cycle_id: @previous_target_cycle.id)
      .discarded
  end
end
