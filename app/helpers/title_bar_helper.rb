# frozen_string_literal: true

module TitleBarHelper
  def render_title_bar?(current_user:, provider:)
    current_user.present? && provider.present?
  end
end
