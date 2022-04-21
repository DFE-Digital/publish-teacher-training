module Publish
  class RolloverRecruitmentController < ApplicationController
    def new; end

    def create
      InterruptPageAcknowledgement.find_or_create_by!(
        user: current_user,
        recruitment_cycle: RecruitmentCycle.current,
        page: "rollover_recruitment",
      )

      redirect_to publish_root_path
    end
  end
end
