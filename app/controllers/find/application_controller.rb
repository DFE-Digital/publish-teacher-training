module Find
  class ApplicationController < ActionController::Base
    layout "find_layout"
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    before_action :redirect_to_maintenance_page_if_flag_is_active

    def render_feedback_component
      @render_feedback_component = true
    end

  private

    def provider
      @provider ||= RecruitmentCycle.current.providers.find_by(provider_code: params[:provider_code])
    end

    def redirect_to_maintenance_page_if_flag_is_active
      redirect_to maintainance_path if FeatureFlag.active?(:maintenance_mode)
    end
  end
end
