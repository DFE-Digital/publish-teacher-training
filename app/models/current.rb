class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :sessionable, to: :session, allow_nil: true
end
