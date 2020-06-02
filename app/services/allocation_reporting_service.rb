class AllocationReportingService
  def initialize(recruitment_cycle_scope: RecruitmentCycle)
    @current = recruitment_cycle_scope
    @previous = recruitment_cycle_scope.previous
  end

  class << self
    def call(recruitment_cycle_scope:)
      new(recruitment_cycle_scope: recruitment_cycle_scope).call
    end
  end

  def call
    {
      previous: reporting(recruitment_cycle: @previous),
      current: reporting(recruitment_cycle: @current),
    }
  end

  private_class_method :new

private

  def reporting(recruitment_cycle: RecruitmentCycle)
    requested_allocations = recruitment_cycle.allocations.not_declined
    distinct_requested_allocations = requested_allocations.distinct
    {
      total: {
        allocations: requested_allocations.count,
        distinct_accredited_bodies: distinct_requested_allocations.select(:accredited_body_id).count,
        distinct_providers: distinct_requested_allocations.select(:provider_id).count,
        number_of_places: requested_allocations.sum(:number_of_places),
      },
    }
  end
end
