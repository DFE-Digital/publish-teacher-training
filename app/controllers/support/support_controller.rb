module Support
  class SupportController < ApplicationController
    layout "support"
    before_action :check_user_is_admin

  private

    def check_user_is_admin
      if !current_user.admin?
        render "errors/forbidden", status: :forbidden, formats: :html
      end
    end

    def recruitment_cycle
      @recruitment_cycle ||= RecruitmentCycle.find_by(year: params.fetch(:recruitment_cycle_year))
    end
  end
end
