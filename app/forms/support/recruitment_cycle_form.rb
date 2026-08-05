# frozen_string_literal: true

module Support
  class RecruitmentCycleForm < ApplicationForm
    attribute :year, :string
    attribute :application_start_date, :multiple_parameters_date
    attribute :application_end_date, :multiple_parameters_date
    attribute :available_for_support_users_from, :multiple_parameters_date
    attribute :available_in_publish_from, :multiple_parameters_date

    validates :year, presence: true, numericality: { only_integer: true }
    validates :application_start_date,
              :application_end_date,
              :available_for_support_users_from,
              :available_in_publish_from,
              multiple_parameters_date: true
    validate :application_end_date_must_be_after_start_date
    validate :application_start_date_must_match_cycle_timetable
    validate :available_for_support_users_from_must_be_before_available_in_publish_from
    validate :year_must_be_unique, if: -> { validation_context != :update }

    def initialize(params = {})
      processed_params = MultipleParametersDateType.process(params)

      super(processed_params)
    end

  private

    def application_end_date_must_be_after_start_date
      return if application_start_date.blank? || application_end_date.blank?

      return unless application_end_date <= application_start_date

      errors.add(:application_start_date, :application_end_date_after_start_date)
      errors.add(:application_end_date, :application_end_date_after_start_date)
    end

    def year_must_be_unique
      return if year.blank?

      errors.add(:year, :taken) if RecruitmentCycle.exists?(year:)
    end

    def application_start_date_must_match_cycle_timetable
      return if year.blank? || application_start_date.blank?
      return unless year.to_s.match?(/\A\d+\z/)
      return if errors[:application_start_date].present?

      expected_application_start_date = Find::CycleTimetable.real_schedule_for(year.to_i)&.fetch(:apply_opens, nil)&.to_date

      if expected_application_start_date.blank?
        errors.add(:application_start_date, :missing_cycle_timetable)
      elsif application_start_date != expected_application_start_date
        errors.add(
          :application_start_date,
          :does_not_match_cycle_timetable,
          date: expected_application_start_date.to_fs(:govuk_date),
        )
      end
    end

    def available_for_support_users_from_must_be_before_available_in_publish_from
      return if available_for_support_users_from.blank? || available_in_publish_from.blank?

      if available_for_support_users_from >= available_in_publish_from
        errors.add(
          :available_for_support_users_from,
          :before_available_in_publish_from,
        )
        errors.add(
          :available_in_publish_from,
          :after_available_for_support_users_from,
        )
      end
    end
  end
end
