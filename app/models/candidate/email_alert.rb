# frozen_string_literal: true

class Candidate
  class EmailAlert < ApplicationRecord
    self.table_name = "candidate_email_alerts"

    belongs_to :candidate

    validates :search_attributes, search_attributes: true

    scope :active, -> { where(unsubscribed_at: nil) }
    scope :subscribed, -> { active }

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
  end
end
