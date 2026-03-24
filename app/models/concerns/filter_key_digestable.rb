# frozen_string_literal: true

module FilterKeyDigestable
  extend ActiveSupport::Concern

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

  def self.compute_digest(subjects:, search_attributes:)
    normalized = normalize_attrs(search_attributes)
    key = [Array(subjects).sort, normalized]
    Digest::SHA256.hexdigest(key.to_json)
  end

  def self.normalize_attrs(attrs)
    (attrs || {}).stringify_keys
      .slice(*FILTER_KEYS)
      .transform_values { |v| v.is_a?(Array) ? v.map(&:to_s) : v.to_s }
  end

  included do
    before_save :set_filter_key_digest, if: :should_recompute_digest?
  end

  def compute_filter_key_digest
    FilterKeyDigestable.compute_digest(subjects: subjects, search_attributes: search_attributes)
  end

  def normalize_filter_attrs(attrs)
    FilterKeyDigestable.normalize_attrs(attrs)
  end

private

  def set_filter_key_digest
    self.filter_key_digest = compute_filter_key_digest
  end

  def should_recompute_digest?
    new_record? || subjects_changed? || search_attributes_changed?
  end

  def subjects_changed?
    will_save_change_to_attribute?(:subjects)
  end

  def search_attributes_changed?
    will_save_change_to_attribute?(:search_attributes)
  end
end
