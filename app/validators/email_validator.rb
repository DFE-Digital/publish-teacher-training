class EmailValidator < ActiveModel::EachValidator
  EMAIL_VALIDATION_ERROR_MESSAGE = "^Enter an email address in the correct format, like name@example.com".freeze

  def validate_each(record, attribute, value)
    if value.blank? || !value.match?(/@/)
      record.errors[attribute] << EMAIL_VALIDATION_ERROR_MESSAGE
    end
  end
end
