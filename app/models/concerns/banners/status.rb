# frozen_string_literal: true

module Banners
  module Status
    extend ActiveSupport::Concern

    included do
      scope :scheduled, ->(now = Time.current) { where("published_at > ?", now) }
      scope :scheduled_order, -> { order(published_at: :asc) }

      scope :active, lambda { |now = Time.current|
        where(published_at: ..now)
          .where("expired_at IS NULL OR expired_at >= ?", now)
      }
      scope :active_order, -> { order(published_at: :desc, expired_at: :asc) }

      scope :expired, ->(now = Time.current) { where("expired_at < ?", now) }
      scope :expired_order, -> { order(expired_at: :desc, published_at: :desc) }

      def status(now = Time.current)
        return :scheduled if scheduled?(now)
        return :active if active?(now)

        :expired
      end

      def scheduled?(now = Time.current)
        published_at > now
      end

      def active?(now = Time.current)
        expiry = expired_at.presence || DateTime::Infinity.new
        (published_at..expiry).cover? now
      end

      def deletable?(now = Time.current)
        scheduled?(now)
      end

      def editable?(now = Time.current)
        !expired?(now)
      end

      def expired?(now = Time.current)
        return false unless expired_at

        expired_at < now
      end
    end
  end
end
