# frozen_string_literal: true

class MultipleParametersDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    potential_date = record.instance_variable_get(:@attributes)[attribute.to_s].value_before_type_cast

    record.errors.add(attribute, :blank) if potential_date.blank?

    Date.new(potential_date.year.to_i, potential_date.month.to_i, potential_date.day.to_i)
  rescue StandardError
    record.errors.add(attribute, :invalid_date)
  end
end
