class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user
  delegate :sessionable, to: :session, allow_nil: true

  def user
    session&.sessionable
  end
end
