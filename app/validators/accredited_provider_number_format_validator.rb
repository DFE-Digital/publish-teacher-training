# frozen_string_literal: true

class AccreditedProviderNumberFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.scitt?
      record.errors.add(attribute, :scitt_format) unless value.to_s.match?(/\A5\d{3}\Z/)
    elsif record.university?
      record.errors.add(attribute, :university_format) unless value.to_s.match?(/\A1\d{3}\Z/)
    end
  end
end
