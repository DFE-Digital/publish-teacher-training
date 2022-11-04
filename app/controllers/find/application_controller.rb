module Find
  class ApplicationController < ActionController::Base
    layout "find_layout"
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    def render_feedback_component
      @render_feedback_component = true
    end

  private

    def provider
      @provider ||= RecruitmentCycle.current.providers.find_by(provider_code: params[:provider_code])
    end
  end
end
