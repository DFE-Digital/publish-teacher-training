# frozen_string_literal: true

class Candidate
  class EmailAlert < ApplicationRecord
    self.table_name = "candidate_email_alerts"

    include FilterKeyDigestable
    MAXIMUM_SUBSCRIPTIONS = 10

    belongs_to :candidate

    validates :search_attributes, search_attributes: true
    validate :subscription_limit_not_reached

    scope :active, -> { where(unsubscribed_at: nil) }
    scope :subscribed, -> { active }

    def matches_search?(subjects:, search_attributes:)
      other_attrs = search_attributes.to_h.stringify_keys
      self.subjects.sort == Array(subjects).sort &&
        normalize_filter_attrs(self.search_attributes) == normalize_filter_attrs(other_attrs)
    end

    def filter_key
      [subjects.sort, normalize_filter_attrs(search_attributes)]
    end

    def search_params
      params = search_attributes.symbolize_keys
      params[:subjects] = subjects if subjects.present?
      params[:longitude] = longitude if longitude.present?
      params[:latitude] = latitude if latitude.present?
      params[:radius] = radius if radius.present?
      params
    end

    def unsubscribe!
      update!(unsubscribed_at: Time.current)
    end

  private

    def subscription_limit_not_reached
      return unless new_record?
      return unless candidate&.email_alerts&.active&.count.to_i >= MAXIMUM_SUBSCRIPTIONS

      errors.add(:base, :subscription_limit_reached)
    end

    def normalize_filter_attrs(attrs)
      attrs.slice(*FILTER_KEYS).transform_values { |v| v.is_a?(Array) ? v.map(&:to_s) : v.to_s }
    end
  end
end
