# frozen_string_literal: true

class RecruitmentCycleCreationService
  include ServicePattern

  include ActiveModel::Model

  attr_accessor :year, :application_start_date, :application_end_date, :available_in_publish_from

  def call
    RecruitmentCycle.create!(
      year: @year,
      application_start_date: @application_start_date,
      application_end_date: @application_end_date,
      available_in_publish_from: @available_in_publish_from,
    )
  end
end
