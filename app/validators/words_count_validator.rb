class WordsCountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    if value.scan(/\S+/).size > options[:maximum]
      record.errors[attribute] << (options[:message] || "^Reduce the word count for #{attribute.to_s.humanize(capitalize: false)}")
    end
  end
end
