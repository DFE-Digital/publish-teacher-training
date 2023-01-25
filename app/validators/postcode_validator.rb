class PostcodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    postcode = UKPostcode.parse(value)
    record.errors.add(attribute, message: options[:message] || "is not valid (for example, BN1 1AA)") unless postcode.full_valid?
  end
end
