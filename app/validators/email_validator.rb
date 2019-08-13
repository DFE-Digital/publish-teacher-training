class EmailValidator < ActiveModel::Validator
  EMAIL_VALIDATION_ERROR_MESSAGE = "^Enter an email address in the correct format, like name@example.com".freeze

  def validate(record)
    if record.email.nil? || record.email.empty? || !record.email.match?(/@/)
      record.errors[:email] << EMAIL_VALIDATION_ERROR_MESSAGE
    end
  end
end
