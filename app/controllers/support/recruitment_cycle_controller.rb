# frozen_string_literal: true

module Support
  class RecruitmentCycleController < ApplicationController
    def index
      @rollover_period = RolloverPeriod.new(current_user:)

      redirect_to support_recruitment_cycle_providers_path(Settings.current_recruitment_cycle_year) unless @rollover_period.active?
    end
  end
end
