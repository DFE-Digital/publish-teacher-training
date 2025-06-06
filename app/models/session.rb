class Session < ApplicationRecord
  belongs_to :sessionable, polymorphic: true

  validates :session_key, presence: true
end
