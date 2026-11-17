# frozen_string_literal: true

require "rails_helper"

module Find
  describe AnalyticsConsentHelper do
    before { FeatureFlag.activate(:find_analytics_consent) }

    it "does not ask for consent on a page rendered for a form submission" do
      helper.request.request_method = "POST"

      expect(helper.show_cookie_banner?).to be(false)
    end
  end
end
