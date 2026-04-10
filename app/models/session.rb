class Session < ApplicationRecord
  INACTIVITY_TIMEOUT = 30.minutes

  belongs_to :sessionable, polymorphic: true

  validates :session_key, presence: true

  def active?
    updated_at > INACTIVITY_TIMEOUT.ago
  end
end
