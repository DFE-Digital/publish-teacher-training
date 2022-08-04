# frozen_string_literal: true

require "rails_helper"

class DfEAnalyticsEventsTestAPIController < APIController
  attr_reader :current_user

  def test
    skip_authorization
    render plain: "T-HEST!"
  end

  def authenticate; end
end

class DfEAnalyticsEventsTestPublicAPIController < PublicAPIController
  attr_reader :current_user

  def test
    skip_authorization
    render plain: "public test"
  end
end

RSpec.describe "DFE Analytics integration" do
  before do
    allow(FeatureService).to receive(:enabled?).with(:send_request_data_to_bigquery).and_return(true)

    Rails.application.routes.draw do
      get "/api/test", to: "dfe_analytics_events_test_api#test"
      get "/api/public/v1/test", to: "dfe_analytics_events_test_public_api#test"
    end
  end

  after do
    Rails.application.reload_routes!
  end

  describe APIController do
    it "sends events using DFE Analytics" do
      expect do
        get "/api/test"
      end.to have_sent_analytics_event_types(:web_request)
    end
  end

  describe PublicAPIController do
    it "sends dfe analytics request event" do
      allow(FeatureService).to receive(:enabled?).with(:send_request_data_to_bigquery).and_return(true)

      expect do
        get "/api/public/v1/test"
      end.to have_sent_analytics_event_types(:web_request)
    end
  end
end
