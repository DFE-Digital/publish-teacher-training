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
  end
end
