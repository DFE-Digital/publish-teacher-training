# frozen_string_literal: true

class PotentialDateTime
  include ActiveModel::Model

  SEGMENTS = { 1 => :year, 2 => :month, 3 => :day, 4 => :hour, 5 => :minute }.freeze
  YEARS = (1000..9999)

  attr_accessor(*SEGMENTS.values, :blank_time)

  def fetch(segment)
    public_send(SEGMENTS[segment]) if SEGMENTS.key?(segment)
  end

  def to_time
    return unless [year, month, day].all? { |part| part.to_s.match?(/\A\d+\z/) }
    return unless [hour, minute].all? { |part| part.blank? || part.to_s.match?(/\A\d+\z/) }
    return unless YEARS.cover?(year.to_i)
    return unless Date.valid_date?(year.to_i, month.to_i, day.to_i)
    return unless hour.to_i.between?(0, 23) && minute.to_i.between?(0, 59)
    return whole_day if [hour, minute].all?(&:blank?)

    Time.zone.local(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i)
  end

private

  def whole_day
    midnight = Time.zone.local(year.to_i, month.to_i, day.to_i)

    blank_time == :end_of_day ? midnight.end_of_day : midnight
  end
end
