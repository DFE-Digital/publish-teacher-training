# frozen_string_literal: true

require "rails_helper"

module Find
  describe CookiePreferencesController do
    before do
      FeatureFlag.activate(:find_analytics_consent)
      request.host = "find-temp.teacherservices.cloud"
      request.cookies["_clck"] = "abc"
    end

    it "expires Clarity's cookie at every domain level it could have been set on without consent" do
      get :show

      expect(Array(response.headers["set-cookie"]).grep(/\A_clck=;/)).to contain_exactly(
        a_string_including("domain=find-temp.teacherservices.cloud"),
        a_string_including("domain=teacherservices.cloud"),
      )
    end

    it "leaves Clarity's cookies alone once analytics cookies are accepted" do
      request.cookies[Settings.cookies.analytics.name] = "granted"

      get :show

      expect(Array(response.headers["set-cookie"]).grep(/_cl/)).to be_empty
    end
  end
end
