class ReferenceNumberFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.blank?

    return record.errors.add "#{attribute.to_s.upcase} cannot be blank" if value.blank? && !options[:allow_blank]

    if value.length > options[:maximum] || value.length < options[:minimum] || !value.match?(/\A-?\d+\Z/)
      record.errors.add attribute, options[:message]
    end
  end
end
