# frozen_string_literal: true

class RecruitmentCycleCreationService
  include ServicePattern

  def initialize(year:, application_start_date:, application_end_date:)
    @year = year
    @application_start_date = application_start_date
    @application_end_date = application_end_date
  end

  def call
    RecruitmentCycle.create!(
      year: @year,
      application_start_date: @application_start_date,
      application_end_date: @application_end_date
    ).tap do |recruitment_cycle|
      RolloverJob.perform_later(recruitment_cycle.id)
    end
  end
end
