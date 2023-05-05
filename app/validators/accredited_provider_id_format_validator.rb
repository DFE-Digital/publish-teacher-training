# frozen_string_literal: true

class AccreditedProviderIdFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.blank?

    if record.lead_school?
      record.errors.add(:provider_type, :format)
    elsif record.scitt?
      record.errors.add(attribute, :format) unless value.to_s.match?(/\A5\d{3}\Z/)
    elsif record.university?
      record.errors.add(attribute, :format) unless value.to_s.match?(/\A1\d{3}\Z/)
    end
  end
end
