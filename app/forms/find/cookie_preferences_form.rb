# frozen_string_literal: true

module Find
  class CookiePreferencesForm
    include ActiveModel::Model

    CONSENT_VALUES = %w[granted denied].freeze

    attr_reader :cookies, :analytics_consent

    validates :analytics_consent, inclusion: { in: CONSENT_VALUES }

    def initialize(cookies, analytics_consent: cookies[Settings.cookies.analytics.name] || "denied")
      @cookies = cookies
      @analytics_consent = analytics_consent
    end

    def save
      return false unless valid?

      cookies[Settings.cookies.analytics.name] = {
        value: analytics_consent,
        expires: 1.year.from_now,
        httponly: true,
        same_site: :lax,
        secure: !Rails.env.in?(%w[development test]),
      }
      true
    end
  end
end
