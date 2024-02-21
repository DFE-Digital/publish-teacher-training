# frozen_string_literal: true

class NavigationBar < ApplicationComponent
  attr_reader :items, :current_path

  def initialize(items:, current_path:, current_user: {}, classes: [], html_attributes: {})
    super(classes:, html_attributes:)
    @items = items
    @current_path = current_path
    @current_user = current_user
  end

  def item_link(item)
    link_params = { class: 'moj-primary-navigation__link' }
    link_params.merge!(aria: { current: 'page' }) if show_current_link?(item)
    govuk_link_to(item[:name], item[:url], **link_params)
  end

  def user_signed_in?
    @current_user.present?
  end

  private

  def show_current_link?(item)
    item.fetch(:current, false) || [item.fetch(:url), item[:additional_url]].compact.any? { |url| current_path.include?(url) }
  end
end
