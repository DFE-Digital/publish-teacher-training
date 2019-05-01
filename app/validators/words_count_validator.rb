class WordsCountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless /^\s*(\S+\s+|\S+$){0,#{options[:maximum]}}$/i.match?(value)
      record.errors[attribute] << (options[:message] || "Reduce the word count for #{attribute.to_s.humanize(capitalize: false)}")
    end
  end
end
