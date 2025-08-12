# frozen_string_literal: true

class WordsCountValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, string)
    @attribute = attribute
    return if string.blank?

    return unless word_count(string) > options[:maximum]

    record.errors.add(
      attribute,
      message:,
    )
  end

  def message
    return options[:message] if options[:message].present?
    return "Reduce the word count for #{options[:message_attribute]}" if options[:message_attribute].present?

    "Reduce the word count for #{@attribute.to_s.humanize(capitalize: false)}"
  end

  def word_count(string)
    string.scan(/\S+/).size
  end
end
