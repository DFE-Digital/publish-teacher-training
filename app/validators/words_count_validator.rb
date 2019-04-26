class WordsCountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      return
    end

    unless /^\s*(\S+\s+|\S+$){0,#{options[:max_words_count]}}$/i.match?(value)
      record.errors[attribute] << (options[:message] || "Exceeded words count")
    end
  end
end
