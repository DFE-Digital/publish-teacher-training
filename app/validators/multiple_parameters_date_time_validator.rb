# frozen_string_literal: true

class MultipleParametersDateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    potential_date_time = record.instance_variable_get(:@attributes)[attribute.to_s].value_before_type_cast

    return unless potential_date_time.is_a?(PotentialDateTime)
    return if potential_date_time.to_time

    record.errors.add(attribute, :invalid_date)
  end
end
