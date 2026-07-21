# frozen_string_literal: true

module Banners
  module Status
    extend ActiveSupport::Concern

    included do
      scope :drafts, -> { where(published_at: nil) }
      scope :not_drafts, -> { where.not(published_at: nil) }
      scope :drafts_order, -> { order(created_at: :desc) }

      scope :scheduled, lambda { |now = Time.current|
        not_drafts.where("published_at > ?", now)
      }
      scope :scheduled_order, -> { order(published_at: :asc) }

      scope :active, lambda { |now = Time.current|
        not_drafts
          .where("tsrange(published_at, COALESCE(expired_at, timestamp 'infinity')::timestamp, '[]') @> ?::timestamp", now)
      }
      scope :active_order, -> { order(published_at: :desc, expired_at: :asc) }

      scope :expired, lambda { |now = Time.current|
        not_drafts.where("COALESCE(expired_at, timestamp 'infinity')::timestamp < ?", now)
      }
      scope :expired_order, -> { order(expired_at: :desc, published_at: :desc) }

      def status(now = Time.current)
        return :draft if draft?
        return :scheduled if scheduled?(now)
        return :active if active?(now)
        return :expired if expired?(now)

        :unknown
      end

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

        expiry = expired_at.presence || DateTime::Infinity.new
        expiry < now
      end
    end
  end
end
