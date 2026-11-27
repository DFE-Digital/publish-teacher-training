# frozen_string_literal: true

class RetentionDeletion < ApplicationRecord
  validates :entity_type, :entity_id, :deleted_records, :deleted_at, presence: true
  validate :deleted_records_map_tables_to_id_strings

  def readonly? = persisted? || super

private

  def deleted_records_map_tables_to_id_strings
    return if deleted_records.blank?
    return if deleted_records.is_a?(Hash) && deleted_records.all? { |table, ids| table.present? && id_strings?(ids) }

    errors.add(:deleted_records, :invalid)
  end

  def id_strings?(ids)
    ids.is_a?(Array) && ids.any? && ids.all? { |id| id.is_a?(String) && id.present? }
  end
end
