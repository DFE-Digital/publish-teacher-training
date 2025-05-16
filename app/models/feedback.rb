class Feedback < ApplicationRecord
  MAX_EXPERIENCE_LENGTH = 1200

  enum :ease_of_use, %w[very_easy easy neither_easy_nor_difficult difficult very_difficult].index_by(&:itself)

  validates :ease_of_use, presence: true
  validates :ease_of_use, inclusion: { in: ease_of_uses.keys }
  validates :experience, presence: true, length: { maximum: 1200 }
end
