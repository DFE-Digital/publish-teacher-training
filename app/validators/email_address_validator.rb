class EmailAddressValidator < ActiveModel::EachValidator
  EMAIL_VALIDATION_ERROR_MESSAGE = "Enter an email address in the correct format, like name@example.com".freeze

  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors.add attribute, (options[:message] || EMAIL_VALIDATION_ERROR_MESSAGE)
    end
  end
end
