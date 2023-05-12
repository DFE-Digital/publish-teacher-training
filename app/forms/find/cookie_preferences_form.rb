# frozen_string_literal: true

module Find
  class CookiePreferencesForm
    include ActiveModel::Model

    ACCEPTED_VALUES = %w[granted denied].freeze

    attr_accessor :analytics_consent, :cookies, :analytics_cookie_name, :expiry_date

    validates :analytics_consent, presence: true, inclusion: { in: ACCEPTED_VALUES }

    def initialize(cookies, params = {})
      @cookies = cookies
      @analytics_cookie_name = Settings.cookies.analytics.name
      @expiry_date = Settings.cookies.expire_after_days.days.from_now
      @analytics_consent = params[:analytics_consent] || cookies[analytics_cookie_name]
    end

    def save
      return unless valid?

      cookies[analytics_cookie_name] = { value: analytics_consent, expires: expiry_date }
    end
  end
end
