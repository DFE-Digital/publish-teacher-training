class PhoneValidator < ActiveModel::EachValidator
  PHONE_VALIDATION_ERROR_MESSAGE = "^Enter a valid telephone number".freeze

  def validate_each(record, attribute, value)
    if value.blank? || is_invalid_phone_number_format?(value)
      record.errors[attribute] << PHONE_VALIDATION_ERROR_MESSAGE
    end
  end

private

  def is_invalid_phone_number_format?(value)
    value.match?(/[^ext()+\. 0-9]/)
  end
end
