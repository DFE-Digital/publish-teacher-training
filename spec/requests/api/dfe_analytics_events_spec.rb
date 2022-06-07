# frozen_string_literal: true

require 'rails_helper'
require 'dfe/analytics/rspec/matchers'

class DfEAnalyticsEventsTestAPIController < APIController
  def test
    skip_authorization
    render plain: "T-HEST!"
  end

  def authenticate
    @current_user = User.last
  end

  attr_reader :current_user
end

RSpec.describe 'DFE Analytics integration' do
    before do
      Rails.application.routes.draw do
        get "/api/test", to: "dfe_analytics_events_test_api#test"
      end
    end

    it "sends events using DFE Analytics" do
      allow(FeatureService).to receive(:enabled?).with(:send_request_data_to_bigquery).and_return(true)

      expect {
        get '/api/test'
      }.to have_sent_analytics_event_types(:web_request)
      Rails.application.reload_routes!
    end
end
