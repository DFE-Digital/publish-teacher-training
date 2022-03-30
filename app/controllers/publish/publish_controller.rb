module Publish
  class PublishController < ApplicationController
    layout "publish"

    after_action :verify_authorized

  private

    def provider
      @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code] || params[:code])
    end

    def recruitment_cycle
      cycle_year = params[:recruitment_cycle_year] || Settings.current_recruitment_cycle_year

      @recruitment_cycle ||= RecruitmentCycle.find_by!(year: cycle_year)
    end

    def show_errors_on_publish?
      params[:display_errors].present?
    end
  end
end
