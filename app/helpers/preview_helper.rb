# frozen_string_literal: true

module PreviewHelper
  def preview?(params)
    params[:action] == 'preview' || params[:action].nil?
  end
end
