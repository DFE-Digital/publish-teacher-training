# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::Banners::PublicationsController" do
  include DfESignInUserHelper

  before do
    host! URI(Settings.base_url).host
    login_user(create(:user, :admin))
  end

  describe "POST /support/banners/:banner_id/publication" do
    context "when the banner cannot be published" do
      it "redirects back with a warning flash" do
        banner = create(:banner, published_at: 3.days.ago, expired_at: 2.days.ago)

        post support_banner_publication_path(banner)

        expect(response).to redirect_to(support_banner_path(banner))
        expect(flash[:warning]).to eq("Banner could not be published")
      end
    end
  end
end
