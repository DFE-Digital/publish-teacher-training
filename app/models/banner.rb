class Banner < ApplicationRecord
  validates :name, presence: true
  validates :name, length: { maximum: 255, minimum: 2 }

  validates :title_heading_level, numericality: { only_integer: true, greater_than: 1, less_than_or_equal_to: 6, allow_nil: true }

  validates :expired_at, comparison: { greater_than_or_equal_to: :published_at, allow_nil: true }

  scope :drafts, -> { where(published_at: nil) }
  scope :not_drafts, -> { where.not(published_at: nil) }

  scope :scheduled, lambda { |now = Time.current|
    not_drafts.where("published_at > ?", now)
  }

  scope :active, lambda { |now = Time.current|
    not_drafts
      .where("tsrange(published_at, COALESCE(expired_at, timestamp 'infinity')::timestamp, '[]') @> ?::timestamp", now)
  }

  scope :expired, lambda { |now = Time.current|
    not_drafts.where("COALESCE(expired_at, timestamp 'infinity')::timestamp < ?", now)
  }

  def draft? = !published_at

  def scheduled?(now = Time.current)
    return false if draft?

    published_at > now
  end

  def active?(now = Time.current)
    return false if draft?

    expiry = expired_at.presence || DateTime::Infinity.new
    active_range = (published_at..expiry)
    active_range.cover? now
  end

  def expired?(now = Time.current)
    return false if draft?

    expired_at.present? && expired_at < now
  end

  def status(now = Time.current)
    return :draft if draft?
    return :scheduled if scheduled?(now)
    return :active if active?(now)
    return :expired if expired?(now)

    :unknown
  end

  def displayed_on
    interfaces = []
    interfaces << :find if display_on_find
    interfaces << :publish if display_on_publish
    interfaces << :support if display_on_support
    interfaces
  end

  def scheduled?(now = Time.current)
    published = published_at.presence
    return false unless published

    published > now
  end
end
