# frozen_string_literal: true

module GotoPreview
  extend ActiveSupport::Concern

  def param_form_key
    raise NotImplementedError
  end

  def goto_preview? = params.dig(param_form_key, :goto_preview) == 'true'
  def goto_provider? = params.dig(param_form_key, :goto_provider) == 'true'
end
