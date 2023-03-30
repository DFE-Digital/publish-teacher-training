# frozen_string_literal: true

module Find
  module GotoPreviewHelper
    def goto_preview_value(param_form_key:, params:)
      params[:goto_preview] || params.dig(param_form_key, :goto_preview)
    end
  end
end
