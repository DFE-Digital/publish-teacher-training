class Feedback < ApplicationRecord
  validates :ease_of_use, presence: true
  validates :experience, presence: true, length: { maximum: 1200 }
end
