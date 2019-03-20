class SiteStatusPolicy
  attr_reader :user, :site_status

  def initialize(user, site_status)
    @user        = user
    @site_status = site_status
  end

  def update?
    site_status&.course&.provider&.in? user.providers
  end
end
