# frozen_string_literal: true

module Support
  class RecruitmentCycleController < ApplicationController
    def index
      @rollover_period = RolloverPeriod.new(current_user:)

      redirect_to support_recruitment_cycle_providers_path(Find::CycleTimetable.cycle_year_for_time(Time.zone.now)) unless @rollover_period.active?
    end
  end
end
