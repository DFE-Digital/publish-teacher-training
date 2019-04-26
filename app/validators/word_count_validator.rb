class WordCountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless /^\s*(\S+\s+|\S+$){0,#{options[:max_word_count]}}$/i.match?(value)
      record.errors[attribute] << (options[:message] || "Exceeded word count")
    end
  end
end
