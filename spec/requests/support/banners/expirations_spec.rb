# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::Banners::ExpirationsController" do
  include DfESignInUserHelper

  before do
    host! URI(Settings.base_url).host
    login_user(create(:user, :admin))
  end

  describe "POST /support/banners/:banner_id/expiration" do
    context "when the banner cannot be expired" do
      it "redirects back with a warning flash" do
        banner = create(:banner, published_at: 1.day.from_now)

        post support_banner_expiration_path(banner)

        expect(response).to redirect_to(support_banner_path(banner))
        expect(flash[:warning]).to eq("Banner could not be expired")
      end
    end
  end
end
