# frozen_string_literal: true

module Find
  module AnalyticsConsentHelper
    def analytics_consent_required?
      FeatureFlag.active?(:find_analytics_consent)
    end

    def analytics_consent
      request.cookie_jar[Settings.cookies.analytics.name]
    end

    def load_clarity?
      Rails.env.production? && (!analytics_consent_required? || analytics_consent == "granted")
    end

    def show_cookie_banner?
      analytics_consent_required? && request.get? && request.path != find_cookies_path &&
        (flash.key?(:analytics_consent) || CookiePreferencesForm::CONSENT_VALUES.exclude?(analytics_consent))
    end
  end
end
