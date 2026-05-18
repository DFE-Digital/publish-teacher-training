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

    def search_params
      params = (search_attributes || {}).symbolize_keys
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
  end
end
