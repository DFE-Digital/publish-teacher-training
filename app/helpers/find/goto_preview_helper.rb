# frozen_string_literal: true

module Find
  module GotoPreviewHelper
    def goto_preview_value(param_form_key:, params:)
      params[:goto_preview] || params.dig(param_form_key, :goto_preview)
    end

    def goto_preview?(param_form_key:, params:)
      goto_preview_value(param_form_key:, params:) == 'true'
    end

    def goto_provider_value(param_form_key:, params:)
      params[:goto_provider] || params.dig(param_form_key, :goto_provider)
    end

    def goto_training_with_disabilities_value(param_form_key:, params:)
      params[:goto_training_with_disabilities] || params.dig(param_form_key, :goto_training_with_disabilities)
    end

    def back_link_path(param_form_key:, params:, provider_code:, recruitment_cycle_year:, course_code:)
      if goto_preview?(param_form_key:, params:)
        preview_publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code)
      else
        publish_provider_recruitment_cycle_course_path(provider_code, recruitment_cycle_year, course_code)
      end
    end
  end
end
