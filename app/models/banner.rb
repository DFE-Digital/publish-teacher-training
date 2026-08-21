class Banner < ApplicationRecord
  include Banners::Status
  validates :name, presence: true
  validates :name, length: { maximum: 255, minimum: 2 }, allow_blank: true

  validates :title, presence: true
  validates :heading, presence: true

  validates :title_heading_level, numericality: { only_integer: true, greater_than: 1, less_than_or_equal_to: 6, allow_nil: true }

  validates :published_at, presence: true, if: -> { expired_at.present? }
  validates :expired_at, comparison: { greater_than_or_equal_to: :published_at }, if: -> { expired_at.present? && published_at.present? }

  validate :displayed_on_an_interface

  scope :display_on_find, -> { where(display_on_find: true) }
  scope :display_on_publish, -> { where(display_on_publish: true) }
  scope :display_on_support, -> { where(display_on_support: true) }

  def expire(now = Time.current)
    update(expired_at: now)
  end

  def publish(now = Time.current)
    update(published_at: now)
  end

  def displayed_on
    interfaces = []
    interfaces << :find if display_on_find
    interfaces << :publish if display_on_publish
    interfaces << :support if display_on_support
    interfaces
  end

private

  def displayed_on_an_interface
    errors.add(:displayed_on, :blank) if displayed_on.empty?
  end
end
