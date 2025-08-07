class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user, :recruitment_cycle
  delegate :sessionable, to: :session, allow_nil: true

  def user
    session&.sessionable
  end

  def recruitment_cycle
    attributes[:recruitment_cycle] || RecruitmentCycle.current_recruitment_cycle
  end
end
