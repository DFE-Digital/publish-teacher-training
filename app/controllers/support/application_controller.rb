# frozen_string_literal: true

module Support
  class ApplicationController < ::ApplicationController
    include Publish::Authentication
    layout "support"
    before_action :check_user_is_admin

    # DFE Analytics namespace
    def current_namespace
      "support"
    end

    helper_method :active_banners

  private

    def check_user_is_admin
      render "errors/forbidden", status: :forbidden, formats: :html unless current_user.admin?
    end

    def recruitment_cycle
      @recruitment_cycle ||= Current.recruitment_cycle = RecruitmentCycle.find_by(year: params.fetch(:recruitment_cycle_year))
    end

    def active_banners
      @active_banners ||= Banner.display_on_support.active.active_order
    end
  end
end
