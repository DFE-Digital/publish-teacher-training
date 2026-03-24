# frozen_string_literal: true

module FilterKeyDigestable
  extend ActiveSupport::Concern

  included do
    before_save :set_filter_key_digest, if: :should_recompute_digest?
  end

  def compute_filter_key_digest
    Find::FilterKeyDigest.digest(subjects: subjects, search_attributes: search_attributes)
  end

  def normalize_filter_attrs(attrs)
    Find::FilterKeyDigest.normalize(attrs)
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
