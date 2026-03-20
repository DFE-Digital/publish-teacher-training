class Session < ApplicationRecord
  USER_TIMEOUT = 2.hours

  belongs_to :sessionable, polymorphic: true

  validates :session_key, presence: true

  def active?
    case sessionable_type
    when "User"
      updated_at > USER_TIMEOUT.ago
    else
      true # Candidate session don't time out yet
    end
  end
end
