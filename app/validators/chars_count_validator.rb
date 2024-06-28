# frozen_string_literal: true

class CharsCountValidator < ActiveModel::EachValidator
  # Rails default Length Validators does not give you the possibility
  # to pass a block for overwriting the too long message when reaches the
  # maximum chars
  #
  #  class Person
  #    validates :name, chars_count: { maximum: 100 }
  #  end
  #
  #  In locale:
  #
  #  activemodel:
  #    errors:
  #      person:
  #        attributes:
  #          name:
  #            chars_count:
  #              one: Name must be %{maximum} characters or less. You have %{count} character too many.
  #              other: Name must be %{maximum} characters or less. You have %{count} characters too many.
  #
  def validate_each(record, attribute, value)
    return unless value && value.length > options[:maximum]

    i18n_key = "#{record.class.i18n_scope}.errors.models.#{record.model_name.i18n_key}.attributes.#{attribute}.chars_count"

    excess_characters = value.length - options[:maximum]
    custom_message = options[:message] || I18n.t(
      i18n_key,
      maximum: options[:maximum],
      count: excess_characters,
      default: 'is too long (maximum is %<maximum>s characters, excess characters: %<count>s)'
    )
    record.errors.add(attribute, custom_message)
  end
end
