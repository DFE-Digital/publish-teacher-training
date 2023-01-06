class NameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if is_invalid_name_format?(value)
      record.errors.add(attribute, message: options[:message])
    end
  end

private

  def is_invalid_name_format?(value)
    !value.match?(/^([^0-9]*)$/)
  end
end
