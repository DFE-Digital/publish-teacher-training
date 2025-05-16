# frozen_string_literal: true

module Support
  class RecruitmentCycleController < ApplicationController
    def index
      redirect_to support_recruitment_cycle_providers_path(Settings.current_recruitment_cycle_year) unless RecruitmentCycle.next_editable_cycles?
    end
  end
end
