# frozen_string_literal: true

class MultipleParametersDateTimeType < ActiveModel::Type::Value
  MULTIPLE_PARAMETER_KEY = /\(\d+i\)\z/

  attr_reader :blank_time

  def initialize(blank_time: :beginning_of_day)
    @blank_time = blank_time
    super()
  end

  def self.process(params, types)
    types.each do |attribute_name, type|
      parts = (1..5).map { |index| params.delete("#{attribute_name}(#{index}i)") }

      next if parts.all?(&:blank?)

      params[attribute_name] = PotentialDateTime.new(
        year: parts[0], month: parts[1], day: parts[2], hour: parts[3], minute: parts[4],
        blank_time: type.blank_time
      )
    end

    params.except(*params.keys.grep(MULTIPLE_PARAMETER_KEY))
  end

  def cast(value)
    if value.is_a?(PotentialDateTime)
      value.to_time || value
    else
      super
    end
  end
end
