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

    it "reports only the mistyped date when the other one is valid" do
      post support_banners_path, params: { banner: {
        name: "Test banner",
        body: "text",
        display_on_find: "1",
        "published_at(1i)" => "2026",
        "published_at(2i)" => "2",
        "published_at(3i)" => "30",
        "published_at(4i)" => "9",
        "published_at(5i)" => "0",
        "expired_at(1i)" => "2026",
        "expired_at(2i)" => "12",
        "expired_at(3i)" => "1",
        "expired_at(4i)" => "17",
        "expired_at(5i)" => "0",
      } }

      summary = Nokogiri::HTML(response.body).css(".govuk-error-summary__list li").map { |item| item.text.strip }

      expect(summary).to contain_exactly("Enter a valid publish date and time")
    end

    it "lists errors in the order the questions are asked" do
      post support_banners_path, params: { banner: {
        name: "Test banner",
        body: "text",
        display_on_find: "false",
        display_on_publish: "false",
        display_on_support: "false",
        "published_at(1i)" => "2O26",
        "published_at(2i)" => "1",
        "published_at(3i)" => "1",
        "published_at(4i)" => "9",
        "published_at(5i)" => "0",
      } }

      summary = Nokogiri::HTML(response.body).css(".govuk-error-summary__list li").map { |item| item.text.strip }

      expect(summary).to eq([
        "Enter a valid publish date and time",
        "Select at least one interface to display the banner on",
      ])
    end

    it "gives back the date parts the support user typed correctly" do
      post support_banners_path, params: { banner: {
        name: "Test banner",
        body: "text",
        display_on_find: "1",
        "published_at(1i)" => "2027",
        "published_at(2i)" => "3",
        "published_at(3i)" => "32",
        "published_at(4i)" => "14",
        "published_at(5i)" => "45",
      } }

      typed = Nokogiri::HTML(response.body)
        .css("input[name^='banner[published_at(']")
        .to_h { |input| [input["name"][/\((\d+i)\)/, 1], input["value"]] }

      expect(typed).to include("1i" => "2027", "2i" => "3", "3i" => "32", "4i" => "14", "5i" => "45")
    end

    it "gives every element on a rejected form a unique id" do
      post support_banners_path, params: { banner: {
        name: "Test banner",
        body: "text",
        display_on_find: "1",
        "published_at(1i)" => "2027",
        "published_at(2i)" => "3",
        "published_at(3i)" => "32",
        "published_at(4i)" => "14",
        "published_at(5i)" => "45",
      } }

      ids = Nokogiri::HTML(response.body).css("[id]").map { |element| element["id"] }

      expect(ids.tally.select { |_, count| count > 1 }).to be_empty
      expect(response.body.scan("Enter a valid publish date and time").size).to eq(2)
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
