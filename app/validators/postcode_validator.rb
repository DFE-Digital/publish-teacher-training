class PostcodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    postcode = UKPostcode.parse(value)
    unless postcode.full_valid?
      record.errors[attribute] << "is not valid (for example, BN1 1AA)"
    end
  end
end
