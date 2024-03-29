# frozen_string_literal: true

module CookiesHelper
  def consented_to_analytics_cookie_value
    request.cookie_jar[Settings.cookies.analytics.name]
  end

  def google_analytics_allowed?
    consented_to_analytics_cookie_value == 'granted'
  end

  def hide_cookie_banner?
    consented_to_analytics_cookie_value =~ /granted|denied/
  end
end
