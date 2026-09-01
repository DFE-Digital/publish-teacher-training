# frozen_string_literal: true

class MultipleParametersDateTimeType < ActiveModel::Type::Value
  def self.process(params)
    params.keys
          .select { |key| key.to_s.match?(/\(\d+i\)\z/) }
          .map { |key| key.to_s.split("(").first }
          .uniq
          .each do |attribute_name|
            parts = (1..5).map { |index| params.delete("#{attribute_name}(#{index}i)") }
            params.delete("#{attribute_name}(6i)")

            next if parts.all?(&:blank?)

            params[attribute_name] = PotentialDateTime.new(
              year: parts[0], month: parts[1], day: parts[2], hour: parts[3], minute: parts[4],
            )
          end

    params
  end

  def cast(value)
    if value.is_a?(PotentialDateTime)
      value.to_time
    else
      super
    end
  end
end
