# frozen_string_literal: true

class Candidate
  class EmailAlert < ApplicationRecord
    self.table_name = "candidate_email_alerts"

    belongs_to :candidate

    validates :search_attributes, search_attributes: true

    scope :active, -> { where(unsubscribed_at: nil) }
    scope :subscribed, -> { active }

    # Keys that determine what courses match — excludes display-only keys
    # (location, formatted_address, radius, order, provider_name, provider_code, subject_code)
    # which are either stored as separate columns or don't affect results.
    FILTER_KEYS = %w[
      applications_open
      can_sponsor_visa
      engineers_teach_physics
      funding
      interview_location
      level
      minimum_degree_required
      qualifications
      send_courses
      start_date
      study_types
    ].freeze

    def matches_search?(subjects:, search_attributes:)
      other_attrs = search_attributes.to_h.stringify_keys
      self.subjects.sort == Array(subjects).sort &&
        self.search_attributes.slice(*FILTER_KEYS) == other_attrs.slice(*FILTER_KEYS)
    end

    def filter_key
      [subjects.sort, search_attributes.slice(*FILTER_KEYS)]
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
