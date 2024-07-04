# frozen_string_literal: true

module PreviewHelper
  def preview?(params)
    params[:action] == 'preview' ||
      params[:action].nil? ||
      (params[:controller] == 'publish/courses/providers' && params[:action] == 'show')
  end
end
