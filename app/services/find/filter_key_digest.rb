# frozen_string_literal: true

module Find
  class FilterKeyDigest
    # Keys that determine what courses match — excludes display-only keys
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

    def self.digest(subjects:, search_attributes:)
      key = [Array(subjects).sort, normalize(search_attributes)]
      Digest::SHA256.hexdigest(key.to_json)
    end

    def self.normalize(attrs)
      (attrs || {}).stringify_keys
        .slice(*FILTER_KEYS)
        .transform_values { |v| v.is_a?(Array) ? v.map(&:to_s) : v.to_s }
    end
  end
end
