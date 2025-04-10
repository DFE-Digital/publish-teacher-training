# frozen_string_literal: true

class MultipleParametersDateType < ActiveModel::Type::Value
  def self.process(params)
    params.keys.select { |key| key.to_s.match?(/\(\d+i\)$/) }.each do |key|
      attribute_name = key.to_s.split("(").first

      year = params.delete("#{attribute_name}(1i)")
      month = params.delete("#{attribute_name}(2i)")
      day = params.delete("#{attribute_name}(3i)")

      params[attribute_name] = PotentialDate.new(year:, month:, day:) if year.present? && month.present? && day.present?
    end

    params
  end

  def cast(value)
    if value.is_a?(PotentialDate)
      begin
        Date.new(value.year.to_i, value.month.to_i, value.day.to_i)
      rescue ArgumentError
        nil
      end
    else
      super
    end
  end
end
