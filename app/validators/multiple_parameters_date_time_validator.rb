# frozen_string_literal: true

class MultipleParametersDateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid_date) if value.is_a?(PotentialDateTime)
  end
end
