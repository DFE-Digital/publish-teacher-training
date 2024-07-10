# frozen_string_literal: true

module PreviewHelper
  def preview?(params)
    params[:action] == 'preview' ||
      params[:action].nil? ||
      (params[:controller] == 'publish/courses/providers' && params[:action] == 'show') ||
      (params[:controller] == 'publish/courses/training_with_disabilities' && params[:action] == 'show')
  end
end
