# frozen_string_literal: true

module Find
  class ApplicationController < ActionController::Base
    include Pagy::Backend
    include DfE::Analytics::Requests

    layout "find"

    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    before_action :redirect_to_cycle_has_ended_if_find_is_down
    before_action :redirect_to_maintenance_page_if_flag_is_active

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    def render_feedback_component
      @render_feedback_component = true
    end

    # DFE Analytics namespace
    def current_namespace
      "find"
    end

  private

    def provider
      @provider ||= RecruitmentCycle.current.providers.find_by(provider_code: params[:provider_code]&.upcase)
    end

    def redirect_to_maintenance_page_if_flag_is_active
      redirect_to find_maintenance_path if FeatureFlag.active?(:maintenance_mode)
    end

    def redirect_to_cycle_has_ended_if_find_is_down
      redirect_to find_cycle_has_ended_path if CycleTimetable.find_down?
    end

    def render_not_found
      render "errors/not_found", status: :not_found
    end
  end
end
