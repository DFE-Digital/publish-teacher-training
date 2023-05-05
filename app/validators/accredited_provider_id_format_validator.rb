# frozen_string_literal: true

class AccreditedProviderIdFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.blank?

    record.errors.add(:provider_type, :format) if record.lead_school?

    return unless record.scitt? || record.university?

    record.errors.add(attribute, :format) if %w[1 5].exclude?(value.to_s[0]) || !value.to_s.match?(/\A\d{4}\Z/)
  end
end
