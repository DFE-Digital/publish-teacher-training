require "rails_helper"

class TestController < ::ApplicationController
  def test
    render plain: "Booyah"
  end

  def sign_in_path
    "/"
  end

  def authenticate
    @current_user = User.last
  end

  attr_reader :current_user
end

class UnauthenticatedTestController < PublicAPIController
  def test
    render plain: "Booyah"
  end
end

xdescribe EmitsRequestEvents, type: :request do
  let!(:user) { create(:user) }

  before do
    Rails.application.routes.draw do
      get "/test", to: "test#test"
      get "/unauthenticated_test", to: "unauthenticated_test#test"
    end
  end

  after do
    Rails.application.reload_routes!
  end

  context "feature is enabled" do
    before { stub_feature(true) }

    it "does send to big query" do
      expect {
        get "/test?foo=bar", headers: {
          "HTTP_USER_AGENT" => "Toaster/1.23",
          "HTTP_REFERER" => "https://example.com/",
          "X-Request-Id" => "iamauuid",
        }
      }.to(have_enqueued_job(SendEventToBigQueryJob))
    end
  end

  context "feature is disabled" do
    before { stub_feature(false) }

    it "doesn't send to big query" do
      expect {
        get "/test?foo=bar", headers: {
          "HTTP_USER_AGENT" => "Toaster/1.23",
          "HTTP_REFERER" => "https://example.com/",
          "X-Request-Id" => "iamauuid",
        }
      }.not_to(have_enqueued_job(SendEventToBigQueryJob))
    end
  end

  context "controller doesn't have a current_user" do
    before do
      stub_feature(true)
    end

    it "does send to big query" do
      expect {
        get "/unauthenticated_test?foo=bar", headers: {
          "HTTP_USER_AGENT" => "Toaster/1.23",
          "HTTP_REFERER" => "https://example.com/",
          "X-Request-Id" => "iamauuid",
        }
      }.to(have_enqueued_job(SendEventToBigQueryJob))
    end
  end

  def stub_feature(enabled)
    allow(FeatureService).to receive(:enabled?).with(:google_analytics).and_return(false)
    allow(FeatureService).to receive(:enabled?).with(:send_request_data_to_bigquery).and_return(enabled)
  end
end
