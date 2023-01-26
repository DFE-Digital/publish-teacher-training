# frozen_string_literal: true

class SitePolicy
  attr_reader :user, :site

  def initialize(user, site)
    @user = user
    @site = site
  end

  def index?
    user.present?
  end

  def show?
    user.admin? || user.providers.include?(site.provider)
  end

  alias update? show?
  alias create? show?
end
