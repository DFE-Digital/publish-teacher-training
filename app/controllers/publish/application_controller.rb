# frozen_string_literal: true

module Publish
  class ApplicationController < ::ApplicationController
    include Authentication
    include SuccessMessage

    before_action :check_interrupt_redirects
    before_action :clear_previous_cycle_year_in_session, unless: -> { RecruitmentCycle.upcoming_cycles_open_to_publish? }

    # Protect every action of a provider
    before_action :authorize_provider

    after_action :verify_authorized

    # DFE Analytics namespace
    def current_namespace
      "publish"
    end

  private

    def provider
      @provider ||= recruitment_cycle.providers.find_by!(provider_code: provider_code_param)
    end

    def recruitment_cycle
      @recruitment_cycle ||= RecruitmentCycle.find_by!(year: cycle_year)
    end

    def cycle_year
      @cycle_year ||= params[:recruitment_cycle_year] || params[:year] || Settings.current_recruitment_cycle_year
    end

    def show_errors_on_publish?
      params[:display_errors].present?
    end

    def check_interrupt_redirects(use_redirect_back_to: true)
      if current_user && !current_user.accepted_terms?
        redirect_to publish_accept_terms_path
      elsif use_redirect_back_to
        redirect_to session[:redirect_back_to] if session[:redirect_back_to].present?
        session.delete(:redirect_back_to)
      end
    end

    def clear_previous_cycle_year_in_session
      return if session[:cycle_year].to_i == Settings.current_recruitment_cycle_year

      session[:cycle_year] = nil
    end

    def authorize_provider
      authorize provider, :show? if provider_code_param.present?
    end

    def provider_code_param
      params[:provider_code] || params[:code]
    end

    def schools_outcome?
      @recruitment_cycle.schools_outcome?
    end
  end
end
