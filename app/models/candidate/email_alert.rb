# frozen_string_literal: true

class Candidate
  class EmailAlert < ApplicationRecord
    self.table_name = "candidate_email_alerts"

    include FilterKeyDigestable

    belongs_to :candidate

    validates :search_attributes, search_attributes: true

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
  end
end
