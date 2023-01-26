class PhoneValidator < ActiveModel::EachValidator
  PHONE_VALIDATION_ERROR_MESSAGE = "^Enter a valid telephone number".freeze

  def validate_each(record, attribute, value)
    record.errors.add(attribute, message: options[:message] || PHONE_VALIDATION_ERROR_MESSAGE) if value.blank? || is_invalid_phone_number_format?(value)
  end

private

  def is_invalid_phone_number_format?(value)
    value.match?(/[^ext()+. 0-9]/)
  end
end
