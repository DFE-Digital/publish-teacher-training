class Banner < ApplicationRecord
  include Banners::Status
  validates :name, presence: true
  validates :name, length: { minimum: 2 }, allow_blank: true
  validates :name, words_count: { maximum: 20, message: :too_long }

  validates :heading, words_count: { maximum: 30, message: :too_long }

  validates :body, presence: true
  validates :body, words_count: { maximum: 200, message: :too_long }

  validates :published_at, presence: true
  validates :expired_at, comparison: { greater_than_or_equal_to: :published_at }, if: -> { expired_at.present? && published_at.present? }

  validate :displayed_on_an_interface

  scope :display_on_find, -> { where(display_on_find: true) }
  scope :display_on_publish, -> { where(display_on_publish: true) }
  scope :display_on_support, -> { where(display_on_support: true) }

  def displayed_on
    interfaces = []
    interfaces << :find if display_on_find
    interfaces << :publish if display_on_publish
    interfaces << :support if display_on_support
    interfaces
  end

private

  def displayed_on_an_interface
    errors.add(:display_on_find, :blank) if displayed_on.empty?
  end
end
