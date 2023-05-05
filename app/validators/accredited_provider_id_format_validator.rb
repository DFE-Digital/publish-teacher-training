# frozen_string_literal: true

class AccreditedProviderIdFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.blank?

    if record.lead_school?
      record.errors.add(:provider_type, :format)
    elsif record.scitt?
      record.errors.add(attribute, :format) if value.to_s[0] != '5' || !value.to_s.match?(/\A\d{4}\Z/)
    elsif record.university?
      record.errors.add(attribute, :format) if value.to_s[0] != '1' || !value.to_s.match?(/\A\d{4}\Z/)
    end
  end
end
