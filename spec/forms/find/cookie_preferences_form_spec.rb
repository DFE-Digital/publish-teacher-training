# frozen_string_literal: true

require "rails_helper"

module Find
  describe CookiePreferencesForm do
    subject(:form) { described_class.new(cookies, analytics_consent:) }

    let(:cookies) { ActionDispatch::TestRequest.create.cookie_jar }

    context "when analytics cookies are accepted" do
      let(:analytics_consent) { "granted" }

      it "remembers the choice for a year, out of reach of scripts" do
        response = ActionDispatch::Response.new

        Timecop.freeze do
          form.save
          cookies.write(response)

          expect(Array(response.headers["set-cookie"]).join("\n"))
            .to include("_consented_to_analytics_cookies=granted")
            .and include("expires=#{1.year.from_now.httpdate}")
            .and include("httponly")
        end
      end
    end

    context "when the choice is neither yes nor no" do
      let(:analytics_consent) { "maybe" }

      it "remembers nothing and says why" do
        expect(form.save).to be(false)
        expect(form.errors[:analytics_consent]).to eq(["Select yes if you want to accept analytics cookies"])
        expect(cookies[Settings.cookies.analytics.name]).to be_nil
      end
    end
  end
end
