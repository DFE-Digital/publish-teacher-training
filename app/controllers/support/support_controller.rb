module Support
  class SupportController < ApplicationController
    layout "support"
    before_action :check_user_is_admin

    # DFE Analytics namespace
    def current_namespace
      "support"
    end

  private

    def check_user_is_admin
      render "errors/forbidden", status: :forbidden, formats: :html unless current_user.admin?
    end

    def recruitment_cycle
      @recruitment_cycle ||= RecruitmentCycle.find_by(year: params.fetch(:recruitment_cycle_year))
    end
  end
end
