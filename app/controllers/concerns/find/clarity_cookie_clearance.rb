# frozen_string_literal: true

module Find
  module ClarityCookieClearance
    extend ActiveSupport::Concern

    CLARITY_COOKIES = %w[_clck _clsk].freeze

    included do
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
