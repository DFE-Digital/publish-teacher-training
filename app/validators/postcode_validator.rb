class PostcodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    postcode = UKPostcode.parse(value)
    unless postcode.full_valid?
      record.errors[attribute] << "not recognised as a UK postcode"
    end
  end
end
