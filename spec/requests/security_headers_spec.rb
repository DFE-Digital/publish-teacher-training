# frozen_string_literal: true

require "rails_helper"

describe "security headers" do
  describe "Permissions-Policy" do
    context "on a Find page", service: :find do
      it "restricts powerful browser features" do
        get "/"

        header = response.headers["Permissions-Policy"]
        expect(header).to be_present
        expect(header).to include("camera=()")
        expect(header).to include("microphone=()")
        expect(header).to include("geolocation=()")
        expect(header).to include("payment=()")
        expect(header).to include("usb=()")
      end
    end

    context "on a Publish page", service: :publish do
      it "restricts powerful browser features" do
        get "/sign-in"

        header = response.headers["Permissions-Policy"]
        expect(header).to be_present
        expect(header).to include("camera=()")
        expect(header).to include("microphone=()")
        expect(header).to include("geolocation=()")
        expect(header).to include("payment=()")
        expect(header).to include("usb=()")
      end
    end
  end
end
