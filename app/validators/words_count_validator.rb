class WordsCountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    if WordsCounted.count(value).token_count > options[:maximum]
      record.errors[attribute] << (options[:message] || "^Reduce the word count for #{attribute.to_s.humanize(capitalize: false)}")
    end
  end
end
