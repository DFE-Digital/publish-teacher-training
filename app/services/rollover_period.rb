# RolloverPeriod determines if there are upcoming recruitment cycles available
# for the given user, considering their role (admin/support or publish).
# It provides methods to check if rollover is active and to
# fetch the relevant cycles for the given user.
#
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

  def recruitment_cycles
    if current_user.admin?
      RecruitmentCycle.cycles_open_to_support
    else
      RecruitmentCycle.current_and_upcoming_cycles_open_to_publish
    end.sort_by(&:year)
  end

private

  def next_cycles_available_for_support_users?
    current_user.admin? && RecruitmentCycle.rollover_cycles_open_to_support.exists?
  end

  def next_cycles_available_for_publish_users?
    RecruitmentCycle.upcoming_cycles_open_to_publish?
  end
end
