# frozen_string_literal: true

module Publish
  class VisaSponsorshipApplicationDeadlineDateForm < ApplicationForm
    CURRENT_STEP = "visa_sponsorship_deadline_date"

    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :visa_sponsorship_application_deadline_at, :datetime
    attribute :course
    attribute :recruitment_cycle
    attribute :starting_step

    validate :date_present
    validate :within_range

    def self.build(year:, month:, day:, recruitment_cycle:, course: nil, starting_step: CURRENT_STEP)
      attributes = {
        visa_sponsorship_application_deadline_at: Struct.new(:year, :month, :day).new(year, month, day),
        course:,
        recruitment_cycle:,
        starting_step:,
      }

      new(attributes)
    end

    def started_at_current_step?
      starting_step == CURRENT_STEP
    end

    def update!
      return unless valid?

      course.update!(visa_sponsorship_application_deadline_at: @date)
    end

    def date_present
      error_type = if [year, month, day].all?(&:blank?)
                     :all_blank
                   elsif [year, month, day].any?(&:blank?)
                     :some_blank
                   elsif [year, month, day].any? { |entry| entry.match?(/\A[a-zA-Z'-]*\z/) }
                     :not_integers
                   end

      errors.add(:visa_sponsorship_application_deadline_at, error_type) if error_type.present?
    end

    def set_date
      @date = Time.zone.local(year.to_i, month.to_i, day.to_i).end_of_day
    end

    def within_range
      set_date

      unless @date.between?(first_valid_datetime, last_valid_datetime)
        errors.add(
          :visa_sponsorship_application_deadline_at,
          :not_in_range,
          earliest_date: formatted_first_valid_datetime,
          apply_deadline: last_valid_datetime.to_fs(:govuk_date_and_time),
        )
      end
    rescue Date::Error
      errors.add(:visa_sponsorship_application_deadline_at, :invalid_date)
    end

    def year
      visa_sponsorship_application_deadline_at&.year
    end

    def month
      visa_sponsorship_application_deadline_at&.month
    end

    def day
      visa_sponsorship_application_deadline_at&.day
    end

    def last_valid_datetime
      @last_valid_datetime ||= Find::CycleTimetable.date(:apply_deadline, recruitment_cycle.year.to_i)
    end

    def first_valid_datetime
      [Time.zone.now, start_of_cycle].max
    end

    def formatted_first_valid_datetime
      if Time.zone.now.after? start_of_cycle
        "today"
      else
        start_of_cycle.to_fs(:govuk_date_and_time)
      end
    end

    def start_of_cycle
      @start_of_cycle ||= recruitment_cycle.application_start_date.end_of_day.change(hour: 9)
    end
  end
end
