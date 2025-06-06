# frozen_string_literal: true

class UkprnFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.blank?

    if value.blank?
      record.errors.add(attribute, :blank)
    elsif value[0] != "1" || !value.match?(/\A\d{8}\Z/)
      record.errors.add(attribute, :contains_eight_numbers_starting_with_one)
    end
  end
end
