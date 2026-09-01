# frozen_string_literal: true

class PotentialDateTime
  include ActiveModel::Model

  PARTS = %i[year month day hour minute].freeze

  attr_accessor(*PARTS)

  def parts
    PARTS.map { |part| public_send(part) }
  end

  def blank?
    parts.all?(&:blank?)
  end

  def to_time
    return unless [year, month, day].all? { |part| part.to_s.match?(/\A\d+\z/) }
    return unless [hour, minute].all? { |part| part.blank? || part.to_s.match?(/\A\d+\z/) }
    return unless Date.valid_date?(year.to_i, month.to_i, day.to_i)
    return unless hour.to_i.between?(0, 23) && minute.to_i.between?(0, 59)

    Time.zone.local(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i)
  end
end
