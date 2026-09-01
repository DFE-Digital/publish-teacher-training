# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support::BannersController" do
  include DfESignInUserHelper

  before do
    host! URI(Settings.base_url).host
    login_user(create(:user, :admin))
  end

  describe "GET /support/banners/:id/edit" do
    it "turns away an expired banner reached by its address" do
      banner = create(:banner, published_at: 3.days.ago, expired_at: 1.day.ago)

      get edit_support_banner_path(banner)

      expect(response).to redirect_to(expired_support_banners_path)
      expect(flash[:warning]).to eq("Expired banners cannot be edited")
    end
  end

  describe "POST /support/banners" do
    it "reports a mistyped date instead of raising" do
      expect {
        post support_banners_path, params: { banner: {
          name: "Test banner",
          body: "text",
          display_on_find: "1",
          "published_at(1i)" => "2026",
          "published_at(2i)" => "1",
          "published_at(3i)" => "32",
          "published_at(4i)" => "9",
          "published_at(5i)" => "0",
        } }
      }.not_to change(Banner, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Enter a valid publish date and time")
    end
  end

  describe "GET /support/banners/expired" do
    it "splits a long list across pages" do
      create_list(:banner, 51, published_at: 3.days.ago, expired_at: 1.day.ago)

      get expired_support_banners_path

      expect(response.body.scan("govuk-table__row").size).to eq(51)
      expect(response.body).to include("govuk-pagination")
    end
  end

  describe "DELETE /support/banners/:id" do
    it "turns away a banner the public has already seen" do
      banner = create(:banner, published_at: 1.day.ago)

      expect { delete support_banner_path(banner) }.not_to change(Banner, :count)

      expect(response).to redirect_to(active_support_banners_path)
      expect(flash[:warning]).to eq("Banners that have been published cannot be deleted")
    end

    it "deletes a banner nobody has seen" do
      banner = create(:banner, published_at: 1.day.from_now)

      expect { delete support_banner_path(banner) }.to change(Banner, :count).by(-1)

      expect(response).to redirect_to(scheduled_support_banners_path)
    end
  end
end
