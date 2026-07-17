class Banner < ApplicationRecord
  validates :name, presence: true
  validates :name, length: { maximum: 255, minimum: 2 }

  validates :title_heading_level, numericality: { only_integer: true, greater_than: 1, less_than_or_equal_to: 6, allow_nil: true }

  validates :expired_at, comparison: { greater_than_or_equal_to: :published_at, allow_nil: true }

  scope :active, lambda { |now = Time.current|
    where.not(published_at: nil)
         .where("tsrange(published_at, COALESCE(expired_at, timestamp 'infinity')::timestamp, '[]') @> ?::timestamp", now)
  }

  def active?(now = Time.current)
    published = published_at.presence
    return false unless published

    expiry = expired_at.presence || DateTime::Infinity.new
    active_range = (published..expiry)
    active_range.cover? now
  end
end
