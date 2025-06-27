class RolloverPeriod
  attr_reader :current_user

  def self.active?(current_user:)
    new(current_user:).active?
  end

  def initialize(current_user:)
    @current_user = current_user
  end

  def active?
    next_cycles_available_for_support_users? || next_cycles_available_for_publish_users?
  end

  def next_recruitment_cycles
    if current_user.admin?
      RecruitmentCycle.next_editable_cycles_via_support
    else
      RecruitmentCycle.next_editable_cycles
    end
  end

private

  def next_cycles_available_for_support_users?
    current_user.admin? && RecruitmentCycle.next_editable_cycles_via_support?
  end

  def next_cycles_available_for_publish_users?
    RecruitmentCycle.next_editable_cycles?
  end
end
