class WordsCountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, string)
    return if string.blank?

    if word_count(string) > options[:maximum]
      record.errors[attribute] << (options[:message] || "^Reduce the word count for #{attribute.to_s.humanize(capitalize: false)}")
    end
  end

  def word_count(string)
    string.scan(/\S+/).size
  end
end
