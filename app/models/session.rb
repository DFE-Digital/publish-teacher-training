class Session < ApplicationRecord
  INACTIVITY_TIMEOUT = 30.minutes

  belongs_to :sessionable, polymorphic: true

  validates :session_key, presence: true

  def active?
    case sessionable_type
    when "User"
      updated_at > INACTIVITY_TIMEOUT.ago
    else
      true # Candidate session don't time out yet
    end
  end
end
