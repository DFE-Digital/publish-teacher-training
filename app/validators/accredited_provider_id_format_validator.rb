# frozen_string_literal: true

class AccreditedProviderIdFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.blank?

    if value.blank?
      record.errors.add(attribute, :blank)
    elsif %w[1 5].exclude?(value.to_s[0]) || !value.to_s.match?(/\A\d{4}\Z/)
      record.errors.add(attribute, :format)
    end
  end
end
