# frozen_string_literal: true

module Find
  module ClarityCookieClearance
    extend ActiveSupport::Concern

    CLARITY_COOKIES = %w[_clck _clsk].freeze

    included do
      # Checked on every request, not only when consent is withdrawn: visitors
      # from before find_analytics_consent went on still carry _clck/_clsk from
      # when Clarity loaded unconditionally, and _clck lasts a year. With the
      # flag on, Clarity only loads once consent is granted, so it cannot set
      # these cookies before then.
      after_action :clear_clarity_cookies, if: :clear_clarity_cookies?
    end

  private

    def clear_clarity_cookies?
      FeatureFlag.active?(:find_analytics_consent) && cookies[Settings.cookies.analytics.name] != "granted"
    end

    def clear_clarity_cookies
      (CLARITY_COOKIES & request.cookies.keys).product(clarity_cookie_domains).each do |name, domain|
        response.delete_cookie(name, domain:, path: "/")
      end
    end

    def clarity_cookie_domains
      labels = request.host.split(".")
      (0...(labels.size - 1)).map { |index| labels.drop(index).join(".") }
    end
  end
end
