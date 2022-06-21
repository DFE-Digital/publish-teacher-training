# frozen_string_literal: true

module CookiesHelper
  def hide_cookie_banner?
    request.cookie_jar[Settings.cookies.consent.name] =~ /yes|no/ || !FeatureService.enabled?(:google_analytics)
  end

  def google_analytics_allowed?
    request.cookie_jar[Settings.cookies.consent.name] == "yes"
  end
end
