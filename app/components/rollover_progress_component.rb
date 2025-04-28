class RolloverProgressComponent < ViewComponent::Base
  attr_reader :current_cycle, :target_cycle

  def initialize(current_cycle:, target_cycle:)
    super
    @current_cycle = current_cycle
    @target_cycle = target_cycle
  end

  def status
    if @target_cycle.upcoming?
      t(".status.message", total_providers:, rolled_over_providers:, percentage_complete:)
    else
      t(".status.default_message")
    end
  end

  def percentage_complete
    return 0 if total_providers.zero? || rolled_over_providers.zero?

    (rolled_over_providers.to_f / total_providers * 100).round(2)
  end

private

  def total_providers
    @total_providers ||= @current_cycle.providers.count
  end

  def rolled_over_providers
    @rolled_over_providers ||= @target_cycle.providers.count
  end
end
