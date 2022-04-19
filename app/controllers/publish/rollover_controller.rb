module Publish
  class RolloverController < ApplicationController
    def new; end

    def create
      InterruptPageAcknowledgement.find_or_create_by!(
        user: current_user,
        recruitment_cycle: RecruitmentCycle.find_by!(year: Settings.current_recruitment_cycle_year),
        page: "rollover",
      )

      redirect_to root_path
    end
  end
end
