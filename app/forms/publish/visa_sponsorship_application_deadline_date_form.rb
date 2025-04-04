# frozen_string_literal: true

module Publish
  class VisaSponsorshipApplicationDeadlineDateForm < ApplicationForm
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :visa_sponsorship_application_deadline_at, :datetime

    validate :date_present
    validate :within_range

    def self.build(attributes, recruitment_cycle:)
      year = attributes["visa_sponsorship_application_deadline_at(1i)"]
      month = attributes["visa_sponsorship_application_deadline_at(2i)"]
      day = attributes["visa_sponsorship_application_deadline_at(3i)"]
      attributes["visa_sponsorship_application_deadline_at"] = Struct.new(:year, :month, :day).new(year, month, day)

      attributes = attributes.except("visa_sponsorship_application_deadline_at(1i)", "visa_sponsorship_application_deadline_at(2i)", "visa_sponsorship_application_deadline_at(3i)")
      new(attributes, recruitment_cycle:)
    end

    def initialize(attributes, recruitment_cycle:)
      @recruitment_cycle = recruitment_cycle
      super(attributes)
    end

    def date_present
      error_type = if [year, month, day].all?(&:blank?)
                     :blank
                   elsif day.blank? || day.to_i.zero?
                     :blank_day
                   elsif month.blank? || month.to_i.zero?
                     :blank_month
                   elsif year.blank? || year.to_i.zero?
                     :blank_year
                   end

      errors.add(:visa_sponsorship_application_deadline_at, error_type) if error_type.present?
    end

    def within_range
      date = Time.zone.local(year.to_i, month.to_i, day.to_i, 23, 59)

      unless date.between?(first_valid_datetime, last_valid_datetime)
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
      @last_valid_datetime ||= @recruitment_cycle.application_end_date.end_of_day.change(hour: 18)
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
      @start_of_cycle ||= @recruitment_cycle.application_start_date.end_of_day.change(hour: 9)
    end
  end
end
